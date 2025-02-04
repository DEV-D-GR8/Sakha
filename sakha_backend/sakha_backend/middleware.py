import firebase_admin
from firebase_admin import auth
from django.http import JsonResponse

class FirebaseAuthenticationMiddleware:
    """
    Middleware that authenticates requests via Firebase JWT.
    """
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # Bypass for admin or static requests if desired
        if request.path.startswith('/admin/'):
            return self.get_response(request)

        auth_header = request.META.get('HTTP_AUTHORIZATION')
        if auth_header:
            try:
                # Expect header format: "Bearer <token>"
                parts = auth_header.split()
                if parts[0].lower() != "bearer" or len(parts) != 2:
                    raise Exception("Invalid token header")
                token = parts[1]
                decoded_token = auth.verify_id_token(token)
                # Attach Firebase user info (e.g., uid, email) to request.
                request.firebase_user = decoded_token
            except Exception as e:
                return JsonResponse({"detail": "Invalid Firebase token."}, status=401)
        else:
            # Optionally enforce authentication on all endpoints:
            return JsonResponse({"detail": "Authorization header missing."}, status=401)

        return self.get_response(request)
