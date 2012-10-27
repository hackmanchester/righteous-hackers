import glob
import yaml
import os
import json
from subprocess import Popen, PIPE
from logging import getLogger
from pusher import Pusher
import pusherclient
import time

from django.conf import settings

log = getLogger(__name__)

def list_tubes():
    tubes = []
    for config in glob.glob(settings.TUBES_ROOT + "/*/config.yml"):
        parsed = parse_config(config)
        if parsed:
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
        return result
    
    def invoke_pusher(self, message):
        log.debug("Should use pusher to send a message to %s", self.name)
        message['target'] = self.name
        self.pusher['messages'].trigger("input", message)
        



class TubeDispatcher(object):
    pusher = None
    
    def run(self):
        if not self.pusher:
            self.connect()
        
        while True:
            time.sleep(1)
    
    
    def connect(self):
        if self.pusher:
            return
        
        connection = None
        
        def connection_handler(data):
            channel = connection.subscribe("messages")
            channel.bind("input", self.input_received)
            channel.bind("output", self.output_received)
        
        connection = pusherclient.Pusher(settings.PUSHER_CONFIG['key'])
        connection.connection.bind('pusher:connection_established', connection_handler)
        
    
    def input_received(self, *args, **kwargs):
        log.debug(args)
        log.debug(kwargs)

    def output_received(self, *args, **kwargs):
        log.debug(args)
        log.debug(kwargs)









