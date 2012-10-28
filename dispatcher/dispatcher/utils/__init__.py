import glob
import yaml
import os
import json
import hmac
from subprocess import Popen, PIPE
from logging import getLogger
from pusher import Pusher
import pusherclient
import time
from hashlib import md5, sha256
import random

from django.conf import settings

log = getLogger(__name__)

INCLUDE_UNSTABLE = False

CHANNEL_NAME = "messages"
PRIVATE_CHANNEL_NAME = "private-messages"

def list_tubes():
    tubes = []
    for config in glob.glob(settings.TUBES_ROOT + "/*/config.yml"):
        parsed = parse_config(config)
        if parsed and (parsed.get('status') == "stable" or INCLUDE_UNSTABLE):
            tubes.append(parsed)
    return [tube['name'] for tube in tubes]

def parse_config(config_path):
    with open(config_path) as stream:
        try:
            return yaml.load(stream)
        except:
            log.error("Couldn't load YAML config from %s", config_path)
            return None

def load_config(tube_name):
    """
    Loads and returns the named tube's parsed config.yml file as a python dict
    """
    config_path = os.path.join(settings.TUBES_ROOT, tube_name, "config.yml")
    if not os.path.isfile(config_path):
        raise ValueError("Tube named '%s' doesn't exist." % tube_name)
    return parse_config(config_path)

class TubeWrapper(object):
    def __init__(self, name):
        for k, v in load_config(name).items():
            setattr(self, k, v)
        
        if not os.path.isfile(self.script_path) and self.invocation_method == "stdin":
            log.error("Couldn't find the tube script for %s", self.name)
        
        if self.is_async:
            self.pusher = Pusher(**settings.PUSHER_CONFIG)
    
    
    @property
    def script_path(self):
        """Return the absolute path to this tube's executable"""
        return os.path.join(settings.TUBES_ROOT, self.name, "tube")
    
    @property
    def is_async(self):
        """
        Returns true if this tube returns its result asynchronously, i.e. via Pusher
        """
        return self.result_method == "pusher"
    
    def process(self, message):
        """Take a message and process it, returning the result if appropriate"""
        if self.invocation_method == "stdin":
            return self.invoke_stdin(message)
        elif self.invocation_method == "pusher":
            return self.invoke_pusher(message)
        else:
            log.warn("WTF is this tube's invocation method?!")
    
    
    def invoke_stdin(self, message):
        log.debug("Going to execute %s", self.script_path)
        encoded = json.dumps(message)
        proc = Popen([self.script_path], stdin=PIPE, stdout=PIPE, cwd=os.path.dirname(self.script_path))
        result = proc.communicate(input=encoded)[0]
        if not self.is_async:
            try:
                result = json.loads(result)
            except:
                log.error("Couldn't get a JSON object from the tube's output...")
                log.error(result)
                return message
        log.debug("Result: %s", result)
        return result
    
    def invoke_pusher(self, message):
        log.debug("Should use pusher to send a message to %s", self.name)
        message['target'] = self.name
        self.pusher[CHANNEL_NAME].trigger("input", message)
        



class TubeDispatcher(object):
    pusherclient = None
    pusher = None
    tubes = None
    
    def __init__(self):
        self.tubes = {name: TubeWrapper(name) for name in list_tubes()}
    
    def run(self):
        if not self.pusherclient:
            self.connectclient()
        
        if not self.pusher:
            self.connect()
        
        while True:
            time.sleep(1)
    
    
    def connectclient(self):
        if self.pusherclient:
            return
        
        def connection_handler(data):
            channel = self.pusherclient.subscribe(CHANNEL_NAME)
            channel.bind("input", self.input_received)
            channel.bind("output", self.output_received)
            
            private_channel = self.pusherclient.subscribe(PRIVATE_CHANNEL_NAME)
            private_channel.bind("client-input", lambda m: self._bounce(CHANNEL_NAME, "input", m))
            private_channel.bind("client-output", lambda m: self._bounce(CHANNEL_NAME, "output", m))
        
        self.pusherclient = pusherclient.Pusher(settings.PUSHER_CONFIG['key'], secret=settings.PUSHER_CONFIG['secret'])
        self.pusherclient.connection.bind('pusher:connection_established', connection_handler)
    
    def connect(self):
        if self.pusher:
            return
        
        self.pusher = Pusher(**settings.PUSHER_CONFIG)
        
    def _bounce(self, channel, event, message):
        self.pusher[channel].trigger(event, json.loads(message))
        
    def input_received(self, data):
        message = json.loads(data)
        if 'target' in message and message['target'] == "dispatcher":
            self.new_message(message['payload'])
        

    def output_received(self, data):
        message = json.loads(data)
        message['through_tubes'].append(message['sender'])
        if 'sender' in message:
            del(message['sender'])
        if 'target' in message:
            del(message['target'])
        self.process_message(message)
        
    
    
    def new_message(self, payload):
        message = {
            "id": md5(payload).hexdigest(),
            "payload": payload,
            "through_tubes": []
        }
        self.process_message(message)
    
    def process_message(self, message):
        log.debug("Processing message: %s", message)
        tube = self.pick_tube_for_message(message)
        if tube is None:
            self.message_finished(message)
            return
        log.debug("Passing message through tube %s", tube.name)
        if tube.is_async:
            log.debug("Tube is async")
            tube.process(message)
        else:
            log.debug("Tube is sync")
            result = tube.process(message)
            result['sender'] = tube.name
            self.pusher[CHANNEL_NAME].trigger("output", result)
        
    def pick_tube_for_message(self, message):
        log.debug("Picking a tube for %s", message)
        candidates = list(set(self.tubes.keys()).difference(set(message['through_tubes'])))
        if not candidates:
            return None
        next_tube = self.tubes[random.choice(candidates)]
        return next_tube

    def message_finished(self, message):
        log.debug("Message has passed through all tubes!")
        self.pusher[CHANNEL_NAME].trigger("finished", message)
        log.debug(message)









