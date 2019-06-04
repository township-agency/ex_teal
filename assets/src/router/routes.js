import Home from '@/views/Home.vue';
import Index from '@/views/Index.vue';
import Detail from '@/views/Detail.vue';
import Create from '@/views/Create.vue';
import Update from '@/views/Update.vue';
import Error403 from '@/views/403.vue';
import Error404 from '@/views/404.vue';

import PageDetail from '@/components/Pages/Detail.vue';
import PageUpdate from '@/components/Pages/Update.vue';

export default [
  {
    path: '/',
    name: 'home',
    component: Home
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
    path: '/pages/:pageKey',
    name: 'page_detail',
    component: PageDetail,
    props: route => {
      return {
        pageKey: route.params.pageKey
      };
    }
  },
  {
    path: '/pages/:pageKey/edit',
    name: 'page_edit',
    component: PageUpdate,
    props: route => {
      return {
        pageKey: route.params.pageKey
      };
    }
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
