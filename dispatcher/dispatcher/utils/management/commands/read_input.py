from logging import getLogger
import random
from hashlib import md5

from django.core.management.base import BaseCommand, CommandError

from dispatcher.utils import list_tubes, TubeWrapper

log = getLogger(__name__)


class Command(BaseCommand):
    def handle(self, *args, **kwargs):
        print "Enter your message: "
        payload = raw_input()
        
        message = {
            "id": md5(payload).hexdigest(),
            "payload": payload
        }
        
        tubes = list_tubes()
        if len(args):
            tube_name = args[0]
        else:
            tube_name = random.choice(tubes)
        tube = TubeWrapper(tube_name)
        
        log.debug("Sending your message to tube '%s'" % tube.name)
        
        result = tube.process(message)
        if tube.is_async:
            log.debug("Sent message, tube is async and so will deliver result whenever..")
        else:
            log.debug("Result: %s" % result)
        
