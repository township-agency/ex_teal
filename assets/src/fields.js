import Vue from 'vue';

import Label from '@/components/Form/Label.vue';
import HelpText from '@/components/Form/HelpText.vue';
import DefaultField from '@/components/Form/DefaultField.vue';
import FieldWrapper from '@/components/Form/FieldWrapper.vue';
import Panel from '@/components/Detail/Panel.vue';
import RelationshipPanel from '@/components/Detail/RelationshipPanel.vue';

Vue.component('form-label', Label);
Vue.component('help-text', HelpText);
Vue.component('default-field', DefaultField);
Vue.component('field-wrapper', FieldWrapper);
Vue.component('panel', Panel);
Vue.component('relationship-panel', RelationshipPanel);

// Text Field...

import IndexTextField from '@/components/Index/TextField.vue';
import DetailTextField from '@/components/Detail/TextField.vue';
import FormTextField from '@/components/Form/TextField.vue';

Vue.component('index-text-field', IndexTextField);
Vue.component('detail-text-field', DetailTextField);
Vue.component('form-text-field', FormTextField);

// Boolean...

import IndexBoolean from '@/components/Index/Boolean.vue';
import DetailBoolean from '@/components/Detail/Boolean.vue';
import FormBoolean from '@/components/Form/Boolean.vue';

Vue.component('index-boolean', IndexBoolean);
Vue.component('detail-boolean', DetailBoolean);
Vue.component('form-boolean', FormBoolean);

// Toggle...

import IndexToggle from '@/components/Index/Toggle.vue';
import DetailToggle from '@/components/Detail/Toggle.vue';
import FormToggle from '@/components/Form/Toggle.vue';

Vue.component('index-toggle', IndexToggle);
Vue.component('detail-toggle', DetailToggle);
Vue.component('form-toggle', FormToggle);

// TextArea...
import IndexTextArea from '@/components/Index/TextArea.vue';
import DetailTextArea from '@/components/Detail/TextArea.vue';
import FormTextArea from '@/components/Form/TextArea.vue';

Vue.component('index-text-area', IndexTextArea);
Vue.component('detail-text-area', DetailTextArea);
Vue.component('form-text-area', FormTextArea);

// Select Box...

import FormSelect from '@/components/Form/Select.vue';

Vue.component('index-select', IndexTextField);
Vue.component('detail-select', DetailTextField);
Vue.component('form-select', FormSelect);

// PasswordField
import PasswordField from '@/components/Form/PasswordField.vue';

Vue.component('index-password-field', IndexTextField);
Vue.component('detail-password-field', DetailTextField);
Vue.component('form-password-field', PasswordField);

// NumberField
import NumberField from '@/components/Form/NumberField.vue';

Vue.component('index-number-field', IndexTextField);
Vue.component('detail-number-field', DetailTextField);
Vue.component('form-number-field', NumberField);

// File

import IndexFile from '@/components/Index/File';
import DetailFile from '@/components/Detail/File';
import FormFile from '@/components/Form/File';

Vue.component('index-file-field', IndexFile);
Vue.component('detail-file-field', DetailFile);
Vue.component('form-file-field', FormFile);

// RichText...
import DetailRichText from '@/components/Detail/RichText.vue';
import FormRichText from '@/components/Form/RichText.vue';

Vue.component('detail-rich-text', DetailRichText);
Vue.component('form-rich-text', FormRichText);

// BelongsTo...

import IndexBelongsTo from '@/components/Index/BelongsTo.vue';
import DetailBelongsTo from '@/components/Detail/BelongsTo.vue';
import FormBelongsTo from '@/components/Form/BelongsTo.vue';

Vue.component('index-belongs-to', IndexBelongsTo);
Vue.component('detail-belongs-to', DetailBelongsTo);
Vue.component('form-belongs-to', FormBelongsTo);

// HasMany...

import DetailHasMany from '@/components/Detail/HasMany.vue';

Vue.component('detail-has-many', DetailHasMany);

// HasOne...

import IndexHasOne from '@/components/Index/HasOne.vue';
import DetailHasOne from '@/components/Detail/HasOne.vue';

Vue.component('index-has-one', IndexHasOne);
Vue.component('detail-has-one', DetailHasOne);

// MultiSelect...
import FormMultiSelect from '@/components/Form/MultiSelect.vue';
import DetailMultiSelect from '@/components/Detail/MultiSelect.vue';

Vue.component('form-multi-select', FormMultiSelect);
Vue.component('detail-multi-select', DetailMultiSelect);

// Date...
import FormDate from '@/components/Form/Date.vue';
import DetailDate from '@/components/Detail/Date.vue';
import IndexDate from '@/components/Index/Date.vue';
Vue.component('form-date', FormDate);
Vue.component('detail-date', DetailDate);
Vue.component('index-date', IndexDate);

// Place...
import FormPlaceField from '@/components/Form/PlaceField.vue';
import DetailPlaceField from '@/components/Detail/PlaceField.vue';
import IndexPlaceField from '@/components/Index/PlaceField.vue';

Vue.component('form-place-field', FormPlaceField);
Vue.component('detail-place-field', DetailPlaceField);
Vue.component('index-place-field', IndexPlaceField);

// Color...
import FormColorField from '@/components/Form/Color.vue';
import DetailColorField from '@/components/Detail/Color.vue';
import IndexColorField from '@/components/Index/Color.vue';

Vue.component('form-color', FormColorField);
Vue.component('detail-color', DetailColorField);
Vue.component('index-color', IndexColorField);
