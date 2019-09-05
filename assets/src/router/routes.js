import Dashboard from '@/views/Dashboard.vue';
import Index from '@/views/Index.vue';
import Detail from '@/views/Detail.vue';
import Create from '@/views/Create.vue';
import Update from '@/views/Update.vue';
import Error403 from '@/views/403.vue';
import Error404 from '@/views/404.vue';
import Attach from '@/views/Attach.vue';
import UpdateAttached from '@/views/UpdateAttached.vue';

export default [
  {
    path: '/',
    name: 'dashboard',
    redirect: to => {
      const uri = window.ExTeal.config.dashboards[0].uri;
      return { name: 'dashboard.custom', params: { uri } };
    }
  },
  {
    path: '/dashboards/:uri',
    name: 'dashboard.custom',
    component: Dashboard,
    props: route => {
      return {
        uri: route.params.uri
      };
    }
  },
  {
    path: '/resources/:resourceName',
    name: 'index',
    component: Index,
    props: route => {
      return {
        resourceName: route.params.resourceName,
        viaResource: route.query.viaResource,
        viaResourceId: Number.parseInt(route.query.viaResourceId),
        viaRelationship: route.query.viaRelationship,
        relationshipType: route.query.relationshipType
      };
    }
  },
  {
    path: '/resources/:resourceName/new',
    name: 'create',
    component: Create,
    props: route => {
      return {
        resourceName: route.params.resourceName,
        viaResource: route.query.viaResource,
        viaResourceId: Number.parseInt(route.query.viaResourceId),
        viaRelationship: route.query.viaRelationship
      };
    }
  },
  {
    name: 'edit',
    path: '/resources/:resourceName/:resourceId/edit',
    component: Update,
    props: route => {
      return {
        resourceName: route.params.resourceName,
        resourceId: Number.parseInt(route.params.resourceId)
      };
    }
  },
  {
    path: '/resources/:resourceName/:resourceId',
    name: 'detail',
    component: Detail,
    props: route => {
      return {
        resourceName: route.params.resourceName,
        resourceId: Number.parseInt(route.params.resourceId)
      };
    }
  },
  {
    name: 'attach',
    path: '/resources/:resourceName/:resourceId/attach/:relatedResourceName',
    component: Attach,
    props: route => {
      return {
        resourceName: route.params.resourceName,
        resourceId: parseInt(route.params.resourceId),
        relatedResourceName: route.params.relatedResourceName,
        viaRelationship: route.query.viaRelationship,
      };
    },
  },
  {
    name: 'edit-attached',
    path: '/resources/:resourceName/:resourceId/edit-attached/:relatedResourceName/:relatedResourceId',
    component: UpdateAttached,
    props: route => {
      return {
        resourceName: route.params.resourceName,
        resourceId: parseInt(route.params.resourceId),
        relatedResourceName: route.params.relatedResourceName,
        relatedResourceId: route.params.relatedResourceId,
        viaRelationship: route.query.viaRelationship,
      };
    },
  },
  {
    name: '403',
    path: '/403',
    component: Error403
  },
  {
    name: '404',
    path: '/404',
    component: Error404
  },
  {
    name: 'catch-all',
    path: '*',
    component: Error404
  }
];
