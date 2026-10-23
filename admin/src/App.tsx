import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { lazy } from 'react';
import { ApiError } from './api/client';
import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';
import { AuthProvider, useAuth } from './auth/AuthContext';
import { Layout } from './components/Layout';
import { ForbiddenPage } from './pages/ForbiddenPage';
import { LoginPage } from './pages/LoginPage';
import { OfflinePage } from './pages/OfflinePage';

// Экраны данных грузятся по требованию (Recharts — отдельный чанк); логин и экраны ошибок — сразу.
const OverviewPage = lazy(() => import('./pages/OverviewPage').then((m) => ({ default: m.OverviewPage })));
const RetentionPage = lazy(() => import('./pages/RetentionPage').then((m) => ({ default: m.RetentionPage })));
const EngagementPage = lazy(() => import('./pages/EngagementPage').then((m) => ({ default: m.EngagementPage })));
const ProductsPage = lazy(() => import('./pages/ProductsPage').then((m) => ({ default: m.ProductsPage })));
const PlatformsPage = lazy(() => import('./pages/PlatformsPage').then((m) => ({ default: m.PlatformsPage })));
const UsersPage = lazy(() => import('./pages/UsersPage').then((m) => ({ default: m.UsersPage })));
const UserDetailPage = lazy(() => import('./pages/UserDetailPage').then((m) => ({ default: m.UserDetailPage })));
const PushPage = lazy(() => import('./pages/PushPage').then((m) => ({ default: m.PushPage })));

/** Один повтор для сети/5xx; 4xx повторять бессмысленно. */
export function shouldRetryQuery(failureCount: number, error: unknown): boolean {
  return !(error instanceof ApiError && error.status >= 400 && error.status < 500) && failureCount < 1;
}

const queryClient = new QueryClient({
  defaultOptions: {
    queries: { retry: shouldRetryQuery, staleTime: 60_000, refetchOnWindowFocus: false },
  },
});

function AppRoutes() {
  const { status } = useAuth();
  if (status === 'checking') {
    return (
      <main className="center" aria-busy="true">
        Загрузка…
      </main>
    );
  }
  if (status === 'signedOut') return <LoginPage />;
  if (status === 'forbidden') return <ForbiddenPage />;
  if (status === 'offline') return <OfflinePage />;

  return (
    <Routes>
      <Route element={<Layout />}>
        <Route index element={<OverviewPage />} />
        <Route path="retention" element={<RetentionPage />} />
        <Route path="engagement" element={<EngagementPage />} />
        <Route path="products" element={<ProductsPage />} />
        <Route path="platforms" element={<PlatformsPage />} />
        <Route path="users" element={<UsersPage />} />
        <Route path="users/:id" element={<UserDetailPage />} />
        <Route path="push" element={<PushPage />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Route>
    </Routes>
  );
}

export function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter future={{ v7_startTransition: true, v7_relativeSplatPath: true }}>
        <AuthProvider onSignOut={() => queryClient.clear()}>
          <AppRoutes />
        </AuthProvider>
      </BrowserRouter>
    </QueryClientProvider>
  );
}
