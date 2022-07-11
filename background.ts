const medium_post_url_regex = RegExp("(/@[^/]+)?/[^@][^/]*-[^/]+")

function redirect(requestDetails: {
    requestId: string;
    url: string;
    method: string;
    frameId: number;
    parentFrameId: number;
    requestBody?: {
      error?: string;
      formData?: { [key: string]: string[] };
      raw?: browser.webRequest.UploadData[];
    };
    tabId: number;
    type: browser.webRequest.ResourceType;
    timeStamp: number;
    originUrl: string;
}) {
  let new_url = new URL(requestDetails.url)
  const path = new_url.pathname

  if (path.startsWith("/m/global-identity")) {
    const url = new_url.searchParams.get('redirectUrl')
    if (!url) return {}
    new_url = new URL(url);
  } else if (!medium_post_url_regex.test(path)) {
    return {}
  }

  new_url.hostname = "scribe.rip"
  new_url.search = ""
  return {
    redirectUrl: new_url.href
  }
}

browser.webRequest.onBeforeRequest.addListener(
  redirect,
  {
    urls: [
      "https://medium.com/*",
      "https://*.medium.com/*",
    ],
    types:["main_frame", "xmlhttprequest", "sub_frame", "other"]
  },
  ["blocking"],
)

export {}
