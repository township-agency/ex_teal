import { CardSizes } from '../util/card-sizes';
import filter from 'lodash/filter';

export const HasCards = {
  props: {
    loadCards: {
      type: Boolean,
      default: true,
    },
  },

  data: () => ({ cards: [] }),

  created () {
    this.fetchCards();
  },

  watch: {
    cardsEndpoint () {
      this.fetchCards();
    },
  },

  methods: {
    async fetchCards () {
      // We disable fetching of cards when the component is being show
      // on a resource detail view to avoid extra network requests
      if (this.loadCards) {
        const { data: { cards: cards } } = await ExTeal.request().get(this.cardsEndpoint, {
          params: this.extraCardParams,
        });
        this.cards = cards;
      }
    },
  },

  computed: {
    shouldShowCards () {
      return this.cards.length > 0;
    },

    smallCards () {
      return filter(this.cards, c => CardSizes.indexOf(c.width) !== -1);
    },

    largeCards () {
      return filter(this.cards, c => c.width == 'full');
    },

    extraCardParams () {
      return null;
    },
  },
};
