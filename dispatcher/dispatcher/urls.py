from django.conf.urls import patterns, include, url

# Uncomment the next two lines to enable the admin:
# from django.contrib import admin
# admin.autodiscover()

urlpatterns = patterns('',
    url(r'^$', 'dispatcher.views.index'),
    url(r'^pusher/auth$', 'dispatcher.views.pusher_auth'),
    
    # Examples:
    # url(r'^$', 'dispatcher.views.home', name='home'),
    # url(r'^dispatcher/', include('dispatcher.foo.urls')),

    # Uncomment the admin/doc line below to enable admin documentation:
    # url(r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    # url(r'^admin/', include(admin.site.urls)),
)
