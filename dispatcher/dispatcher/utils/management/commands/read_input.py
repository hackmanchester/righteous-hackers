from logging import getLogger
from pusher import Pusher

from django.core.management.base import BaseCommand, CommandError
from django.conf import settings


log = getLogger(__name__)


class Command(BaseCommand):
    def handle(self, *args, **kwargs):
        print "Enter your message: "
        payload = raw_input()
        
        message = {
            "payload": payload,
            "target": "dispatcher"
        }
        
        pusher = Pusher(**settings.PUSHER_CONFIG)
        
        pusher['messages'].trigger('input', message)
