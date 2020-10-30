import { DateTime } from 'luxon';

const formatKeys = {
  'date_short': DateTime.DATE_SHORT,
  'date_med': DateTime.DATE_MED,
  'date_full': DateTime.DATE_FULL,
  'date_huge': DateTime.DATE_HUGE,
  'time_simple': DateTime.TIME_SIMPLE,
  'time_with_seconds': DateTime.TIME_WITH_SECONDS,
  'time_with_short_offset': DateTime.TIME_WITH_SHORT_OFFSET,
  'time_with_long_offset': DateTime.TIME_WITH_LONG_OFFSET,
  'time_24_simple': DateTime.TIME_24_SIMPLE,
  'time_24_with_seconds': DateTime.TIME_24_WITH_SECONDS,
  'time_24_with_short_offset': DateTime.TIME_24_WITH_SHORT_OFFSET,
  'time_24_with_long_offset': DateTime.TIME_24_WITH_LONG_OFFSET,
  'datetime_short': DateTime.DATETIME_SHORT,
  'datetime_med': DateTime.DATETIME_MED,
  'datetime_full': DateTime.DATETIME_FULL,
  'datetime_huge': DateTime.DATETIME_HUGE,
  'datetime_short_with_seconds': DateTime.DATETIME_SHORT_WITH_SECONDS,
  'datetime_med_with_seconds': DateTime.DATETIME_MED_WITH_SECONDS,
  'datetime_full_with_seconds': DateTime.DATETIME_FULL_WITH_SECONDS,
  'datetime_huge_with_seconds': DateTime.DATETIME_HUGE_WITH_SECONDS,
};

const InteractsWithDateTimes = {
  computed: {
    format () {
      const key = this.naiveDateTime ? 'datetime_med' : 'datetime_full';
      return this.field.options.format ? formatKeys[this.field.options.format] : formatKeys[key];
    },

    naiveDateTime () {
      return this.field.options.naive_datetime || false;
    },

    formattedDate () {

      return DateTime.fromISO(this.field.value).toLocaleString(this.format);
    }
  }
};

export default InteractsWithDateTimes;