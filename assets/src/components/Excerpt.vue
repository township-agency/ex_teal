<template>
  <div v-if="hasContent">
    <a
      class="cursor-pointer dim inline-block text-primary font-bold"
      aria-role="button"
      @click="toggle"
    >
      {{ showHideLabel }}
    </a>
    <div
      v-if="expanded"
      class="show-content"
      v-html="content"
    />
    <div
      v-else
      class="hidden-content"
      v-html="content"
    />
  </div>
  <div v-else>
    —
  </div>
</template>

<script>
export default {
  props: {
    content: {
      type: String,
      default: ''
    }
  },

  data: () => ({ expanded: false }),

  computed: {
    showHideLabel () {
      return !this.expanded ? 'Show Content' : 'Hide Content';
    },

    hasContent () {
      return this.content && this.content !== '';
    }
  },

  methods: {
    toggle () {
      this.expanded = !this.expanded;
    }
  }
};
</script>
