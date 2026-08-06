"""Background-worker process placeholder for later phases."""

import logging

LOGGER = logging.getLogger(__name__)


def main() -> None:
    """Explain that asynchronous domain jobs are not active in Phase 1."""
    logging.basicConfig(level=logging.INFO)
    LOGGER.info("Cineara worker is reserved for later background tasks.")


if __name__ == "__main__":
    main()
