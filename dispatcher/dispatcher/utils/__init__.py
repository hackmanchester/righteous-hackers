import glob
import yaml
from logging import getLogger

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