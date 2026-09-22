import re


def extract_urls(text: str) -> list[str]:
    """
    Extract HTTP/HTTPS URLs from a message.

    Returns a unique list of URLs.
    """

    pattern = re.compile(
        r'https?://[^\s<>"\']+',
        re.IGNORECASE,
    )

    matches = pattern.findall(text)

    urls = []

    for url in matches:
        # Remove punctuation that commonly appears immediately
        # after a URL in normal sentences.
        url = url.rstrip(".,!?;:)")

        if url and url not in urls:
            urls.append(url)

    return urls