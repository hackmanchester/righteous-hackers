import glob
import yaml
import os
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
    
    
    def process(self, msg):
        return msg