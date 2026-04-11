import {
  DashboardOutlined,
  ShopOutlined,
  TeamOutlined,    
  AppstoreOutlined, 
  StarOutlined,     
  CalendarOutlined, 
  WalletOutlined,   
  SettingOutlined,  
  LogoutOutlined,
  HistoryOutlined,
  BankOutlined
} from '@ant-design/icons';

export const adminMenuItems = [
  { key: '/dashboard', icon: <DashboardOutlined />, label: 'Tổng quan' },
  { key: '/stores', icon: <ShopOutlined />, label: 'Quản lý Cửa hàng' },
  { key: '/users', icon: <TeamOutlined />, label: 'Quản lý Người dùng' },
  { key: '/categories', icon: <AppstoreOutlined />, label: 'Danh mục Dịch vụ' },
  { key: '/reviews', icon: <StarOutlined />, label: 'Kiểm duyệt Đánh giá' },
  { key: '/bookings', icon: <CalendarOutlined />, label: 'Quản lý Lịch hẹn' },
 {
        key: 'finance',
        icon: <WalletOutlined />,
        label: 'Tài chính & Giao dịch',
        children: [
            {
                key: '/finance/transactions', 
                icon: <HistoryOutlined />,
                label: 'Lịch sử giao dịch',
            },
            {
                key: '/finance/withdrawals',
                icon: <BankOutlined />,
                label: 'Yêu cầu rút tiền',
            },
        ],
    },
 { 
    key: 'system-group',
    icon: <SettingOutlined />, 
    label: 'Cài đặt Hệ thống',
    children: [
      { key: '/settings/contents', label: 'Nội dung hệ thống' }, 
      {
          key: '/settings/configs', 
          label: 'Cấu hình Hệ thống' 
      }
    ]
  }
];