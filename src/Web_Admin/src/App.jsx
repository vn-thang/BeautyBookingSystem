import { BrowserRouter } from 'react-router-dom';
import { ConfigProvider } from 'antd'; 
import viVN from 'antd/locale/vi_VN'; 
import AppRoutes from '@/routes/AppRoutes';

function App() {
  return (
    <ConfigProvider
      locale={viVN} 
      theme={{
        token: {
          colorPrimary: '#4318FF', 
          colorInfo: '#4318FF',
          colorSuccess: '#10B981', 
          colorError: '#EF4444',  
          colorWarning: '#F59E0B',
          fontFamily: "'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif",
          borderRadius: 8, 
          colorTextBase: '#1E293B', 
        },
        components: {
          Table: {
            headerBg: '#F8FAFC', 
            headerColor: '#475569', 
            rowHoverBg: '#F1F5F9',
          },
          Card: {
            paddingLG: 24, 
          }
        }
      }}
    >
      <BrowserRouter>
        <AppRoutes />
      </BrowserRouter>
    </ConfigProvider>
  );
}

export default App;