"""External service integrations used by Cineara.

This package contains adapters and clients for third-party services consumed by
the Cineara backend.

Integration-specific networking, raw external models, endpoint definitions, and
error handling belong inside their respective subpackages.

Application and domain logic should depend on integration facades or services
rather than on low-level transport implementations.
"""
