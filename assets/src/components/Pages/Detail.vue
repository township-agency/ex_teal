<template>
  <loading-view :loading="initialLoading">
    <div
      v-for="(panel, index) in availablePanels"
      :key="panel.key"
      class="mb-8">
      <component
        :is="panel.component"
        :class="{'remove-bottom-border': index == panel.fields.length - 1}"
        :resource-name="pageKey"
        :resource-id="pageKey"
        :resource="page"
        :panel="panel"
      >
        <div
          v-if="panel.name.includes('Details')"
          class="card-headline">
          <h2 class="text-90 font-normal text-xl">{{ panel.name }}</h2>
          <div class="ml-auto flex">
            <router-link
              :to="{ name: 'page_edit', params: {pageKey: pageKey} }"
              data-testid="edit-resource"
              dusk="edit-resource-button"
              class="btn btn-default btn-icon btn-primary"
              title="Edit"
            >
              <icon
                type="edit"
                class="text-white"
                style="margin-top: -2px; margin-left: 3px" />
            </router-link>
          </div>

        </div>

      </component>
    </div>
  </loading-view>
</template>

<script>
import _ from "lodash";
export default {
  props: {
    pageKey: {
      type: String,
      required: true
    }
  },

  data: () => ({
    initialLoading: true,
    loading: true,

    page: null,
    panels: []
  }),

  computed: {
    /**
     * Get the available field panels.
     */
    availablePanels() {
      if (this.page) {
        var panels = {};

        var fields = _.toArray(JSON.parse(JSON.stringify(this.page.fields)));

        fields.forEach(field => {
          if (field.options.child_component) {
            return (panels[field.name] = this.createPanelForArray(field));
          } else if (field.component == "resource-field") {
            return (panels[field.name] = this.createPanelForRelationship(
              field
            ));
          } else if (panels[field.panel]) {
            return panels[field.panel].fields.push(field);
          }

          panels[field.panel] = this.createPanelForField(field);
        });

        return _.toArray(panels);
      }
    }
  },

  watch: {
    pageKey: function(newKey, oldKey) {
      if (newKey != oldKey) {
        this.initializeComponent();
      }
    }
  },

  /**
   * Mount the component.
   */
  mounted() {
    this.initializeComponent();
  },

  methods: {
    async initializeComponent() {
      await this.getPage();
      this.initialLoading = false;
    },

    getPage() {
      this.page = null;

      return ExTeal.request()
        .get(`/plugins/pages/${this.pageKey}`)
        .then(({ data: { panels, fields } }) => {
          this.panels = panels;
          this.page = { fields };
          this.loading = false;
        });
    },

    /**
     * Create a new panel for the given field.
     */
    createPanelForField(field) {
      return _.tap(
        _.find(this.panels, panel => panel.key == field.panel),
        panel => {
          panel.component = "panel";
          panel.fields = [field];
        }
      );
    },

    /**
     * Create a new panel for the given relationship field.
     */
    createPanelForArray(field) {
      let component = field.options.child_component;
      let fields = _.map(field.value, ({ content, title }) => {
        return {
          ...field,
          component,
          options: field.options,
          value: content,
          name: title
        };
      });

      return {
        component: "pages-array-panel",
        prefixComponent: true,
        name: field.name,
        fields
      };
    },

    /**
     * Create a new panel for the given relationship field.
     */
    createPanelForRelationship(field) {
      return {
        component: "relationship-panel",
        prefixComponent: true,
        name: field.name,
        fields: [field]
      };
    }
  }
};
</script>
