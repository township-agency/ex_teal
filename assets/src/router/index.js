import Vue from "vue";
import Router from "vue-router";
import routes from "./routes";

Vue.use(Router);

let base = window.config ? window.config.base : "http://localhost:4000/teal";

const router = createRouter({ base });

export default router;

function createRouter({ base }) {
  const router = new Router({
    base,
    mode: "history",
    routes
  });

  return router;
}
