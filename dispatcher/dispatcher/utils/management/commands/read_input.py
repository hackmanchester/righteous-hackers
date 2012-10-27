from logging import getLogger
import random

from django.core.management.base import BaseCommand, CommandError

from dispatcher.utils import list_tubes, TubeWrapper

log = getLogger(__name__)


class Command(BaseCommand):
    def handle(self, *args, **kwargs):
        print "Enter your message: "
        msg = raw_input()
        tubes = list_tubes()
        tube = TubeWrapper(random.choice(tubes))
        
        log.debug("Sending your message to tube '%s'" % tube.name)
        
        log.debug("Result: %s" % tube.process(msg))
        
