import Vue from 'vue';
import Router from 'vue-router';
import routes from './routes';

Vue.use(Router);

const router = createRouter({ base: window.config.path });

export default router;

function createRouter ({ base }) {
  const router = new Router({
    base,
    mode: 'history',
    routes
  });

  router.beforeEach(beforeEach);
  router.afterEach(afterEach);

  return router;
}

/**
 * Global router guard.
 *
 * @param {Route} to
 * @param {Route} from
 * @param {Function} next
 */
async function beforeEach (to, from, next) {
  // Get the matched components and resolve them.
  const components = await resolveComponents(router.getMatchedComponents({ ...to }));

  if (components.length === 0) {
    return next();
  }

  next();
}

/**
 * Global after hook.
 *
 * @param {Route} to
 * @param {Route} from
 * @param {Function} next
 */
async function afterEach (to, from, next) {
  await router.app.$nextTick();
}

/**
 * Resolve async components.
 *
 * @param  {Array} components
 * @return {Array}
 */
function resolveComponents (components) {
  return Promise.all(
    components.map(component => {
      return typeof component === 'function' ? component() : component;
    })
  );
}