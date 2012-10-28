import json
from pusher import Pusher
from pusherclient import Pusher as PusherClient
import time

class BaseTube(object):
    CHANNEL_NAME = "messages"
    PRIVATE_CHANNEL_NAME = "private-messages"

    PUSHER_CONFIG = {
        "app_id": '30507',
        "key": 'afefd11a8f69dd2a425d',
        "secret": '6f034e7a52ece851ea77'
    }
    
    pusher = None
    pusherclient = None
    sleep_length = 1
    
    def __init__(self, name):
        self.name = name
        self.connect()
        self.connectclient()
    
    def run(self):
        while True:
            self.tick()
            time.sleep(self.sleep_length)
    
    def tick(self):
        pass

    def connectclient(self):
        if self.pusherclient:
            return

        def connection_handler(data):
            channel = self.pusherclient.subscribe(self.CHANNEL_NAME)
            channel.bind("input", self.input_received)

            private_channel = self.pusherclient.subscribe(self.PRIVATE_CHANNEL_NAME)
            # private_channel.bind("client-input", lambda m: self._bounce(self.CHANNEL_NAME, "input", m))

        self.pusherclient = PusherClient(self.PUSHER_CONFIG['key'], secret=self.PUSHER_CONFIG['secret'])
        self.pusherclient.connection.bind('pusher:connection_established', connection_handler)

    def connect(self):
        if self.pusher:
            return
        self.pusher = Pusher(**self.PUSHER_CONFIG)
    
    def input_received(self, message):
        message = json.loads(message)
        if message.get("target") == self.name:
            del(message['target'])
            self.handle(message)
    
    def handle(self, message):
        self.return_message(message)
    
    def return_message(self, message):
        if 'target' in message:
            del(message['target'])
        message['sender'] = self.name
        self.pusher[self.CHANNEL_NAME].trigger("output", message)
    
    def processing(self, message, encoding_scheme, encoded_payload):
        message['encoding_scheme'] = encoding_scheme
        message['encoded_payload'] = encoded_payload
        self.pusher[self.CHANNEL_NAME].trigger("processing", message)
        del(message['encoding_scheme'])
        del(message['encoded_payload'])
    