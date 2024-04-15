import axios from 'axios';
import router from '@/router';

const instance = axios.create({
  baseURL: window.config.path
    ? `${window.location.origin}${window.config.path}`
    : 'http://localhost:4000/teal'
});

instance.interceptors.response.use(
  response => response,
  error => {
    const { status } = error.response;
    // Show the user a 500 error
    if (status >= 500) {
      window.ExTeal.$emit('error', 'An unknown server error has occurred');
    }

    // Handle Session Timeouts
    if (status === 401) {
      window.location = '/auth/login';
    }

    if (status === 404) {
      window.ExTeal.$emit('error', 'NOT FOUND');
    }

    // Handle Forbidden
    if (status === 403) {
      router.push({ name: '403' });
    }

    return Promise.reject(error);
  }
);

instance.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest';
instance.defaults.headers.common['X-CSRF-TOKEN'] = document.head.querySelector( 'meta[name="csrf-token"]').content;

export default instance;
