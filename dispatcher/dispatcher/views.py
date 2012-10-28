from logging import getLogger
import json
from hashlib import sha256
import hmac

from django.views.generic import TemplateView, View
from django.http import HttpResponse
from django.conf import settings

from dispatcher.utils import list_tubes

log = getLogger(__name__)

class IndexView(TemplateView):
    template_name = "index.html"
index = IndexView.as_view()

class PusherAuthView(View):
    def post(self, *args, **kwargs):
        # log.debug(args)
        # log.debug(kwargs)
        channel = self.request.POST['channel_name']
        socket = self.request.POST['socket_id']
        msg = "%s:%s" % (socket, channel)
        hashed = hmac.new(settings.PUSHER_CONFIG['secret'], msg=msg, digestmod=sha256).hexdigest()
        auth = json.dumps(dict(auth="%s:%s" % (settings.PUSHER_CONFIG['key'], hashed)))
        log.debug(auth)
        return HttpResponse(auth)
pusher_auth = PusherAuthView.as_view()

class TubeList(View):
    def get(self, *args, **kwargs):
        return HttpResponse(json.dumps(list_tubes()))
tube_list = TubeList.as_view()
