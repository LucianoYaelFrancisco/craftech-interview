from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status


@api_view(['GET'])
def health_check(request):
    """
    Health check endpoint para load balancer.
    Devuelve 200 OK si el servicio está healthy.
    
    Usado por:
    - ALB health checks
    - Kubernetes readiness/liveness probes
    """
    return Response(
        {
            "status": "healthy",
            "message": "Interview API is running"
        },
        status=status.HTTP_200_OK
    )
