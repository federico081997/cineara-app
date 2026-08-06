"""Scheduled-job process placeholder for later phases."""

import logging

LOGGER = logging.getLogger(__name__)


def main() -> None:
    """Explain that scheduled domain jobs are not active in Phase 1."""
    logging.basicConfig(level=logging.INFO)
    LOGGER.info("Cineara scheduler is reserved for later scheduled tasks.")


if __name__ == "__main__":
    main()
