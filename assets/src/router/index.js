import Vue from "vue";
import Router from "vue-router";
import routes from "./routes";

Vue.use(Router);

const router = createRouter({ base: window.config.base || "/teal" });

export default router;

function createRouter({ base }) {
  const router = new Router({
    base,
    mode: "history",
    routes
  });

  return router;
}
