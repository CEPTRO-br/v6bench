import sys
import httpx

print("sitecustomize loaded: httpx verify disabled", file=sys.stderr)

def _force_noverify(cls):
    orig = cls.__init__
    def patched(self, *args, **kwargs):
        kwargs["verify"] = False
        orig(self, *args, **kwargs)
    cls.__init__ = patched

# Patch the transports too: when a Client is given an explicit transport
# (ScanAPI imports HTTPTransport, probably for retries), the Client's own
# `verify` argument is ignored and the transport's setting wins.
for name in ("Client", "AsyncClient", "HTTPTransport", "AsyncHTTPTransport"):
    _force_noverify(getattr(httpx, name))
