<template>
  <div class="flex justify-center items-centers">
    <div class="w-full">
      <heading class="flex mb-3">
        Get Started
      </heading>
      <p class="text-gray-darkest leading-tight mb-8">
        Welcome to Teal! Get familiar with Teal and explore its features in the
        documentation:
      </p>

      <card>
        <table
          class="w-full"
          cellpadding="0"
          cellspacing="0"
        >
          <tr>
            <td class="align-top w-1/2 border-r border-b border-gray">
              <a
                :href="resources"
                class="no-underline dim flex p-6"
              >
                <div class="flex justify-center w-11 flex-no-shrink mr-6 text-primary">
                  <icon
                    type="view"
                    width="44"
                    height="44"
                  />
                </div>

                <div>
                  <heading
                    :level="3"
                    class="mb-3"
                  >Resources</heading>
                  <p class="text-gray-darkest leading-normal">
                    Teal's resource manager allows you to quickly view and
                    manage your Ecto schemas and relationships directly from Teal's
                    intuitive interface.
                  </p>
                </div>
              </a>
            </td>

            <td class="align-top w-1/2 border-b border-gray">
              <a
                :href="actions"
                class="no-underline dim flex p-6"
              >
                <div class="flex justify-center w-11 flex-no-shrink mr-6 text-primary">
                  <icon
                    type="action"
                    width="44"
                    height="44"
                  />
                </div>

                <div>
                  <heading
                    :level="3"
                    class="mb-3"
                  >Actions</heading>
                  <p class="text-gray-darkest leading-normal">
                    Actions perform tasks on a single record or an entire batch
                    of records.
                  </p>
                </div>
              </a>
            </td>
          </tr>

          <tr>
            <td class="align-top w-1/2 border-r border-b border-gray">
              <a
                :href="filters"
                class="no-underline dim flex p-6"
              >
                <div class="flex justify-center w-11 flex-no-shrink mr-6 text-primary">
                  <icon
                    type="filter"
                    width="44"
                    height="44"
                  />
                </div>

                <div>
                  <heading
                    :level="3"
                    class="mb-3"
                  >Filters</heading>
                  <p class="text-gray-darkest leading-normal">
                    Write custom filters for your resource and relationship indexes
                    to offer your users quick glances at different segments of your data.
                  </p>
                </div>
              </a>
            </td>
            <td class="align-top w-1/2 border-r border-b border-gray">
              <a
                :href="metrics"
                class="no-underline dim flex p-6"
              >
                <div class="flex justify-center w-11 flex-no-shrink mr-6 fill-current text-primary">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="37"
                    height="36"
                    viewBox="0 0 20 20"
                  >
                    <path
                      d="M1.25,18.75V0H0v20h20v-1.25H1.25z M15,5.375h-1.25v11H15V5.375z M12.5,9.375h-1.25v7h1.25V9.375z M17.5,2.375h-1.25v14
    h1.25V2.375z M10,12.375H8.75v4H10V12.375z M5,10.375H3.75v6H5V10.375z M7.5,7.375H6.25v9H7.5V7.375z"
                    />
                  </svg>
                </div>

                <div>
                  <heading
                    :level="3"
                    class="mb-3"
                  >Metrics</heading>
                  <p class="text-gray-darkest leading-normal">
                    Teal makes it painless to quickly display custom metrics for
                    your application. To put the cherry on top, we’ve included
                    query helpers to make it all easy as pie.
                  </p>
                </div>
              </a>
            </td>
          </tr>
        </table>
      </card>
    </div>
  </div>
</template>

<script>
function link (path) {
  return `https://motel.hexdocs.pm/ex_teal/${path}`;
}

export default {
  props: {
    card: {
      type: Object,
      required: true,
    }
  },

  computed: {
    resources: () => link('resources'),
    actions: () => link('actions/defining-actions.html'),
    filters: () => link('filters/defining-filters.html'),
    lenses: () => link('lenses/defining-lenses.html'),
    metrics: () => link('metrics/defining-metrics.html'),
    cards: () => link('customization/cards.html'),
  },
};
</script>
