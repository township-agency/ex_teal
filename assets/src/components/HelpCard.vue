<template>
  <div class="flex justify-center items-centers">
    <div class="w-full max-w-xl">
      <heading class="flex mb-3">
        Get Started
      </heading>
      <p class="text-90 leading-tight mb-8">
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
            <td class="align-top w-1/2 border-r border-b border-50">
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
                  <p class="text-90 leading-normal">
                    Teal's resource manager allows you to quickly view and
                    manage your Ecto schemas and relationships directly from Teal's
                    intuitive interface.
                  </p>
                </div>
              </a>
            </td>

            <td class="align-top w-1/2 border-b border-50">
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
                  <p class="text-90 leading-normal">
                    Actions perform tasks on a single record or an entire batch
                    of records.
                  </p>
                </div>
              </a>
            </td>
          </tr>

          <tr>
            <td class="align-top w-1/2 border-r border-b border-50">
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
                  <p class="text-90 leading-normal">
                    Write custom filters for your resource and relationship indexes
                    to offer your users quick glances at different segments of your data.
                  </p>
                </div>
              </a>
            </td>
            <td class="align-top w-1/2 border-r border-b border-50">
              <a
                :href="metrics"
                class="no-underline dim flex p-6"
              >
                <div class="flex justify-center w-11 flex-no-shrink mr-6">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="37"
                    height="36"
                    viewBox="0 0 37 36"
                  >
                    <path
                      fill="var(--primary)"
                      d="M2 27h3c1.1045695 0 2 .8954305 2 2v5c0 1.1045695-.8954305 2-2 2H2c-1.1045695 0-2-.8954305-2-2v-5c0-1.1.9-2 2-2zm0 2v5h3v-5H2zm10-11h3c1.1045695 0 2 .8954305 2 2v14c0 1.1045695-.8954305 2-2 2h-3c-1.1045695 0-2-.8954305-2-2V20c0-1.1.9-2 2-2zm0 2v14h3V20h-3zM22 9h3c1.1045695 0 2 .8954305 2 2v23c0 1.1045695-.8954305 2-2 2h-3c-1.1045695 0-2-.8954305-2-2V11c0-1.1.9-2 2-2zm0 2v23h3V11h-3zM32 0h3c1.1045695 0 2 .8954305 2 2v32c0 1.1045695-.8954305 2-2 2h-3c-1.1045695 0-2-.8954305-2-2V2c0-1.1.9-2 2-2zm0 2v32h3V2h-3z"
                    />
                  </svg>
                </div>

                <div>
                  <heading
                    :level="3"
                    class="mb-3"
                  >Metrics</heading>
                  <p class="text-90 leading-normal">
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
