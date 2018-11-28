import axios from "axios";
import router from "@/router";

const instance = axios.create({
  baseURL: window.config ? window.config.baseUrl : "http://localhost:4000/teal"
});

instance.interceptors.response.use(
  response => response,
  error => {
    console.log(error);
    const { status } = error.response;
    // Show the user a 500 error
    if (status >= 500) {
      window.teal.$emit("error", error.response.data.message);
    }

    // Handle Session Timeouts
    if (status === 401) {
      window.location = "/auth/login";
    }

    if (status === 404) {
      window.teal.$emit("error", "NOT FOUND");
    }

    // Handle Forbidden
    if (status === 403) {
      router.push({ name: "403" });
    }

    return Promise.reject(error);
  }
);

export default instance;
