import Vue from 'vue';

import ActionSelector from '@/components/ActionSelector';
import Card from '@/components/Card';
import Checkbox from '@/components/Checkbox';
import CheckboxWithLabel from '@/components/CheckboxWithLabel';
import ConfirmActionModal from '@/components/Modals/ConfirmActionModal';
import CreateResourceButton from '@/components/CreateResourceButton';
import DeleteMenu from '@/components/DeleteMenu';
import DeleteResourceModal from '@/components/Modals/DeleteResourceModal';
import Dropdown from '@/components/Dropdown';
import DropdownMenu from '@/components/DropdownMenu';
import DropdownTrigger from '@/components/DropdownTrigger';
import Editor from '@/components/Editor';
import Error403 from '@/views/Error403';
import Error404 from '@/views/Error404';
import FakeCheckbox from '@/components/FakeCheckbox';
import FilterSelect from '@/components/FilterSelect';
import FilterSelector from '@/components/FilterSelector';
import Heading from '@/components/Heading';
import Index from './views/Index';
import Loader from '@/components/Icons/Loader';
import LoadingCard from '@/components/LoadingCard';
import LoadingView from '@/components/LoadingView';
import Modal from '@/components/Modal';
import PaginationLinks from '@/components/PaginationLinks';
import PanelItem from '@/components/PanelItem';
import ResourceTable from '@/components/ResourceTable';
import ResourceTableRow from '@/components/Index/ResourceTableRow';
import SearchInput from '@/components/SearchInput';
import SelectControl from '@/components/Controls/SelectControl';
import SortableIcon from '@/components/Index/SortableIcon';
import ValidationErrors from '@/components/ValidationErrors';

import Icon from '@/components/Icons/Icon';
import Action from '@/components/Icons/Action';
import Create from '@/components/Icons/Create';
import Delete from '@/components/Icons/Delete';
import Drag from '@/components/Icons/Drag';
import Edit from '@/components/Icons/Edit';
import Filter from '@/components/Icons/Filter';
import Link from '@/components/Icons/Link';
import Reorder from '@/components/Icons/Reorder';
import View from '@/components/Icons/View';

Vue.component('action-selector', ActionSelector);
Vue.component('card', Card);
Vue.component('checkbox', Checkbox);
Vue.component('checkbox-with-label', CheckboxWithLabel);
Vue.component('confirm-action-modal', ConfirmActionModal);
Vue.component('create-resource-button', CreateResourceButton);
Vue.component('delete-menu', DeleteMenu);
Vue.component('delete-resource-modal', DeleteResourceModal);
Vue.component('dropdown', Dropdown);
Vue.component('dropdown-menu', DropdownMenu);
Vue.component('dropdown-trigger', DropdownTrigger);
Vue.component('editor', Editor);
Vue.component('error-403', Error403);
Vue.component('error-404', Error404);
Vue.component('fake-checkbox', FakeCheckbox);
Vue.component('filter-select', FilterSelect);
Vue.component('filter-selector', FilterSelector);
Vue.component('heading', Heading);
Vue.component('loader', Loader);
Vue.component('loading-card', LoadingCard);
Vue.component('loading-view', LoadingView);
Vue.component('modal', Modal);
Vue.component('pagination-links', PaginationLinks);
Vue.component('panel-item', PanelItem);
Vue.component('resource-index', Index);
Vue.component('resource-table', ResourceTable);
Vue.component('resource-table-row', ResourceTableRow);
Vue.component('search-input', SearchInput);
Vue.component('select-control', SelectControl);
Vue.component('sortable-icon', SortableIcon);
Vue.component('validation-errors', ValidationErrors);

Vue.component('icon', Icon);
Vue.component('icon-action', Action);
Vue.component('icon-create', Create);
Vue.component('icon-delete', Delete);
Vue.component('icon-drag', Drag);
Vue.component('icon-edit', Edit);
Vue.component('icon-filter', Filter);
Vue.component('icon-link', Link);
Vue.component('icon-reorder', Reorder);
Vue.component('icon-view', View);