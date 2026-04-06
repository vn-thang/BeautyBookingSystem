import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from '@/features/auth/components/AuthContext'; // Thêm import này
import AdminLayout from '@/layouts/AdminLayout';
import StoreList from '@/features/store/pages/StoreList';
import StoreDetail from '@/features/store/pages/StoreDetail';
import LoginPage from '@/features/auth/pages/LoginPage';
import UserList from '@/features/user/pages/UserList';
import UserDetail from '@/features/user/pages/UserDetail';
import CategoryPage from '@/features/categories/pages/CategoryPage';
import ReviewPage from '@/features/review/pages/ReviewPage';
import BookingPage from '@/features/booking/layouts/BookingPage';
import SystemConfigPage from '@/features/systemConfig/pages/SystemConfigPage';
import DashboardPage from '@/features/dashboard/pages/DashboardPage';
import SystemContentPage from '@/features/systemContent/pages/SystemContentPage';
import PublicPolicyPage from '@/features/systemContent/pages/PublicPolicyPage';
import AllPoliciesPage from '@/features/systemContent/pages/AllPoliciesPage';
import WalletHistoryPage from '@/features/wallet/pages/WalletHistoryPage';
import WithdrawalPage from '@/features/wallet/pages/WithdrawalPage';

const ProtectedRoute = ({ children }) => {
  const { isAuthenticated } = useAuth(); 
  
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  return children;
};
const AppRoutes = () => {
  return (
    <Routes>
      <Route path="/public/policy/:type" element={<PublicPolicyPage />} />
      <Route path="/chinh-sach-chung" element={<AllPoliciesPage />} />
      <Route path="/login" element={<LoginPage />} />
      <Route 
        path="/" 
        element={
          <ProtectedRoute>
            <AdminLayout />
          </ProtectedRoute>
        }
      >
        <Route index element={<Navigate to="/dashboard" replace />} />
        <Route path="dashboard" element={<DashboardPage />} />
        <Route path="stores" element={<StoreList />} />
        <Route path="stores/:id" element={<StoreDetail />} />
        <Route path="users" element={<UserList />} />
        <Route path="users/:id" element={<UserDetail />} />
        <Route path="categories" element={<CategoryPage/>} />
        <Route path="reviews" element={< ReviewPage/>} />
        <Route path="bookings" element={<BookingPage />} />
        <Route path="finance/transactions" element={<WalletHistoryPage />} />
         <Route path="finance/withdrawals" element={<WithdrawalPage />} />

        <Route path="settings/contents" element={<SystemContentPage />} />
        <Route path="settings/configs" element={<SystemConfigPage />} />

        <Route path="*" element={<Navigate to="/dashboard" replace />} />
      </Route>
    </Routes>
  );
};

export default AppRoutes;