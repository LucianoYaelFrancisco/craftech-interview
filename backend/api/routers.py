from django.urls import path
from api.authentication.viewsets import (
    RegisterViewSet,
    LoginViewSet,
    ActiveSessionViewSet,
    LogoutViewSet,
)
from rest_framework import routers
from api.user.viewsets import UserViewSet
from api.views import health_check

router = routers.SimpleRouter(trailing_slash=False)

router.register(r"edit", UserViewSet, basename="user-edit")

router.register(r"register", RegisterViewSet, basename="register")

router.register(r"login", LoginViewSet, basename="login")

router.register(r"checkSession", ActiveSessionViewSet, basename="check-session")

router.register(r"logout", LogoutViewSet, basename="logout")

urlpatterns = [
    path("health/", health_check, name="health-check"),
    *router.urls,
]
