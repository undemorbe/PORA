import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';
import { AuthProvider, useAuth } from './auth/AuthContext';
import { Layout } from './components/Layout';
import { EngagementPage } from './pages/EngagementPage';
import { ForbiddenPage } from './pages/ForbiddenPage';
import { LoginPage } from './pages/LoginPage';
import { OfflinePage } from './pages/OfflinePage';
import { OverviewPage } from './pages/OverviewPage';
import { PlatformsPage } from './pages/PlatformsPage';
import { ProductsPage } from './pages/ProductsPage';
import { PushPage } from './pages/PushPage';
import { RetentionPage } from './pages/RetentionPage';
import { UserDetailPage } from './pages/UserDetailPage';
import { UsersPage } from './pages/UsersPage';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: { retry: 1, staleTime: 60_000, refetchOnWindowFocus: false },
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
