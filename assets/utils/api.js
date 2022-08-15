import axios from "axios";

const API = "/api";

function commonHeaders() {
  return {
    Accept: "application/json",
  };
}

const headers = () =>
  Object.assign(commonHeaders(), { "Content-Type": "application/json" });

const multipart_headers = () =>
  Object.assign(commonHeaders(), { "Content-Type": "multipart/form-data" });

function queryString(params) {
  const query = Object.keys(params)
    .map((k) => `${encodeURIComponent(k)}=${encodeURIComponent(params[k])}`)
    .join("&");
  return `${query.length ? "?" : ""}${query}`;
}

export default {
  fetch(url, params = {}) {
    return axios.get(`${API}/${url}${queryString(params)}`, {
      headers: headers(),
    });
  },

  upload(verb, url, data) {
    switch (verb.toLowerCase()) {
      case "post":
        return axios.post(`${API}/${url}`, data, { headers: headers() });
      case "put":
        return axios.put(`${API}/${url}`, data, { headers: headers() });
      case "patch":
        return axios.patch(`${API}/${url}`, data, { headers: headers() });
    }
  },

  post(url, data) {
    return axios({
      method: "post",
      url: `${API}/${url}`,
      data: data,
      headers: headers(),
      timeout: 7200000,
    });
  },

  put(url, data) {
    return axios.put(`${API}/${url}`, data, { headers: headers() });
  },

  patch(url, data) {
    return axios.patch(`${API}/${url}`, data, { headers: headers() });
  },

  delete(url) {
    return axios.delete(`${API}/${url}`, { headers: headers() });
  },
  multi(apiCalls) {
    if (!apiCalls || !apiCalls.length || apiCalls.length === 0) {
      return null;
    }
    return axios.all(apiCalls);
  },
  post_form_data(url, formData) {
    return axios.post(`${API}/${url}`, formData, {
      headers: multipart_headers(),
    });
  },
  downloadBinary(url, mimeType) {
    const headers = Object.assign(commonHeaders(), {
      "Content-Type": "application/json",
      Accept: mimeType,
    });
    return axios.get(`${API}/${url}`, {
      responseType: "arraybuffer",
      headers: headers,
    });
  },
  catchHandler(error) {
    console.log('api error:', error)
  },
};
