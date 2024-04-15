<template>
  <div
    :key="cardKey"
    class="p-3 w-full"
    :class="widthClass"
  >
    <component
      :is="card.component"
      :class="cardSizeClass"
      :card="card"
      :resource="resource"
      :resource-name="resourceName"
      :resource-id="resourceId"
    />
  </div>
</template>

<script>

const CardSizes = [ '1/2', '1/3', '2/3', '1/4', '3/4' ];

export default {
  props: {
    card: {
      type: Object,
      required: true,
    },

    resource: {
      type: Object,
      default () { return {}; }
    },

    resourceName: {
      type: String,
      required: false,
      default: ''
    },

    resourceId: {
      type: [ Number, String ],
      default: ''
    }
  },

  computed: {
    widthClass () {
      return this.card.width == 'full' ? 'w-full' : calculateCardWidth(this.card);
    },

    cardSizeClass () {
      return this.size !== 'large' ? 'card-wrapper-panel' : '';
    },

    cardKey () {
      const { component, options: { uri } } = this.card;
      return `metric-${component}-${uri}`;
    }
  }
};

function calculateCardWidth (card) {
  let width;

  switch (card.width) {
    case '1/2':
      width = 'xl:w-1/2';
      break;
    case '1/3':
      width = 'xl:w-1/3';
      break;
    case '2/3':
      width = 'xl:w-2/3';
      break;
    case '1/4':
      width = 'xl:w-1/4';
      break;
    case '3/4':
      width = 'xl:w-3/4';
      break;
  }

  return `w-full lg:w-1/2 ${width}`;
}
</script>
