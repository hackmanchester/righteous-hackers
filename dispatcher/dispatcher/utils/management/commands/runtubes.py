from django.core.management.base import BaseCommand, CommandError

from logging import getLogger

from dispatcher.utils import list_tubes

log = getLogger(__name__)


class Command(BaseCommand):
    def handle(self, *args, **kwargs):
        log.debug("Available tubes: %s", ", ".join(list_tubes()))
