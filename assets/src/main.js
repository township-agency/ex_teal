import Vue from 'vue';
import ExTeal from './ExTeal';

Vue.config.productionTip = false;
import 'phoenix_html';

import './components';
import './fields';

Vue.config.ignoredElements = [ 'trix-editor' ];

/**
 * Finally, we'll create this Vue Router instance and register all of the
 * ExTeal routes. Once that is complete, we will create the Vue instance
 * and hand this router to the Vue instance. Then ExTeal is all ready!
 */
(function () {
  this.CreateExTeal = function (config) {
    return new ExTeal(config);
  };
}.call(window));
