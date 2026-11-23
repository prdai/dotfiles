const MAX_LINKS = 25;
const MAX_CODES = 10;
const MAX_CODE_DIGITS = 8;
const MIN_CODE_DIGITS = 4;

const LINK_PATTERN = /https?:\/\/[^\s<>"'`]+/g;
const HREF_PATTERN = /href\s*=\s*["']([^"']+)["']/gi;
const CODE_PATTERN = new RegExp(`\\b\\d{${MIN_CODE_DIGITS},${MAX_CODE_DIGITS}}\\b`, "g");

export function htmlToText(html: string): string {
  return html
    .replace(/<style[\s\S]*?<\/style>/gi, " ")
    .replace(/<script[\s\S]*?<\/script>/gi, " ")
    .replace(/<[^>]+>/g, " ")
    .replace(/&nbsp;/gi, " ")
    .replace(/&amp;/gi, "&")
    .replace(/&lt;/gi, "<")
    .replace(/&gt;/gi, ">")
    .replace(/&quot;/gi, '"')
    .replace(/&#39;/gi, "'")
    .replace(/\s+/g, " ")
    .trim();
}

export function extractLinks(text: string, html: string): string[] {
  const links = new Set<string>();

  for (const match of text.matchAll(LINK_PATTERN)) {
    links.add(trimTrailingPunctuation(match[0]));
  }
  for (const match of html.matchAll(HREF_PATTERN)) {
    const href = match[1];
    if (href) links.add(decodeEntities(href));
  }
  for (const match of html.matchAll(LINK_PATTERN)) {
    links.add(trimTrailingPunctuation(decodeEntities(match[0])));
  }

  return [...links].filter(isHttpUrl).slice(0, MAX_LINKS);
}

export function extractCodes(text: string): string[] {
  const codes = new Set<string>();

  for (const match of text.matchAll(CODE_PATTERN)) {
    codes.add(match[0]);
  }
  return [...codes].slice(0, MAX_CODES);
}

function trimTrailingPunctuation(url: string): string {
  return url.replace(/[.,;:!?)\]}>]+$/, "");
}

function decodeEntities(value: string): string {
  return value.replace(/&amp;/gi, "&");
}

function isHttpUrl(value: string): boolean {
  try {
    const { protocol } = new URL(value);
    return protocol === "http:" || protocol === "https:";
  } catch {
    return false;
  }
}
