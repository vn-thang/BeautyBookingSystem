import React, { useState } from 'react';
import { Layout, Menu, message, Dropdown, Avatar, Button } from 'antd'; 
import { 
  UserOutlined, 
  KeyOutlined, 
  MenuFoldOutlined, 
  MenuUnfoldOutlined,
  LogoutOutlined
} from '@ant-design/icons'; 
import { Outlet, useNavigate, useLocation } from 'react-router-dom';

import { useAuth } from '@/features/auth/components/AuthContext';
import { authApi } from '@/features/auth/api/authApi';
import { adminMenuItems } from '@/config/menu.config';
import ChangePasswordModal from '@/features/auth/components/ChangePasswordModal';

const { Header, Content, Footer, Sider } = Layout;

const AdminLayout = () => {
  const [collapsed, setCollapsed] = useState(false);
  const navigate = useNavigate();
  const location = useLocation();
  const { logout, user } = useAuth(); 

  const [isPwdModalOpen, setIsPwdModalOpen] = useState(false);

  const handleMenuClick = async ({ key }) => {
    navigate(key); 
  };

  const handleUserMenuClick = async ({ key }) => {
    if (key === 'change_pwd') {
      setIsPwdModalOpen(true);
    }
    if (key === 'logout') {
      try {
        await authApi.logout(); 
        message.success('Đã đăng xuất thành công!');
      } catch (error) {
        console.error('Lỗi đăng xuất:', error);
      } finally {
        logout(); 
      }
    }
  };

  const userDropdownItems = [
    { type: 'divider', style: { margin: 0, borderColor: 'rgba(255,255,255,0.1)' } }, 
    { 
      key: 'change_pwd', 
      icon: <KeyOutlined style={{ fontSize: '14px' }} className="menu-item-icon" />, 
      label: <span style={{ fontWeight: 600, fontSize: '14px' }}>Đổi mật khẩu</span>,
      className: 'dark-hover-menu-item'
    },
    { 
      key: 'logout', 
      icon: <LogoutOutlined style={{ fontSize: '14px' }} className="menu-item-icon" />, 
      label: <span style={{ fontWeight: 600, fontSize: '14px' }}>Đăng xuất</span>, 
      className: 'dark-hover-menu-item dark-hover-danger'
    }
  ];

  const menuProps = {
    items: userDropdownItems,
    onClick: handleUserMenuClick,
    style: { 
      width: 235, 
      padding: '8px', 
      backgroundColor: '#1E293B', 
      borderRadius: '16px',
      border: '1px solid rgba(255,255,255,0.1)', 
      boxShadow: '0 10px 30px rgba(0,0,0,0.5)' 
    } 
  };

  return (
    <Layout style={{ minHeight: '100vh', background: '#F4F7FE' }}>
      
      <style>{`
        /* ĐỒNG BỘ FONT 14PX VÀ MÀU TRẮNG HỒNG NHẠT CHO MENU */
        .ant-menu-dark .ant-menu-item, 
        .ant-menu-dark .ant-menu-submenu-title {
          font-size: 14px !important;
          color: #FDF2F8 !important; 
        }

        .ant-menu-dark .ant-menu-item-selected {
          color: #ffffff !important;
        }

        /* Ẩn background trắng mặc định của item disable (vùng info) */
        .ant-dropdown-menu-item-disabled {
          background-color: transparent !important;
          cursor: default !important;
        }

        .dark-hover-menu-item {
          padding: 12px 16px !important;
          border-radius: 8px !important;
          margin-top: 4px !important;
          transition: all 0.2s ease;
          color: #f8e5ef !important; /* Trắng hồng nhạt */
          font-size: 14px !important;
        }
        
        .dark-hover-menu-item span {
          font-size: 14px !important;
        }
        
        .dark-hover-menu-item .menu-item-icon {
          color: #818CF8 !important; /* Icon mặc định màu xanh sáng */
        }

        /* Hover đổi mật khẩu -> Nền xanh, chữ trắng */
        .dark-hover-menu-item:not(.dark-hover-danger):hover {
          background-color: #4318FF !important; 
          color: #ffffff !important;          
        }
        .dark-hover-menu-item:not(.dark-hover-danger):hover .menu-item-icon {
          color: #ffffff !important;
        }

        /* Nút đăng xuất mặc định có nền hơi đỏ mờ */
        .dark-hover-danger {
          background-color: rgba(239, 68, 68, 0.1) !important;
          color: #FCA5A5 !important;
        }
        .dark-hover-danger .menu-item-icon {
          color: #EF4444 !important; 
        }

        /* Hover đăng xuất -> Nền đỏ rực, chữ trắng */
        .dark-hover-danger:hover {
          background-color: #EF4444 !important; 
          color: #ffffff !important;          
        }
        .dark-hover-danger:hover .menu-item-icon {
          color: #ffffff !important;
        }
      `}</style>

      <Sider 
        collapsible 
        collapsed={collapsed} 
        onCollapse={setCollapsed} 
        trigger={null} 
        theme="dark" 
        width={280} 
        collapsedWidth={80} 
        style={{ 
          boxShadow: '4px 0 24px rgba(0, 0, 0, 0.05)', 
          zIndex: 100,
          background: '#1E293B',
          overflowY: 'auto', 
          height: '100vh',  
          position: 'fixed', 
          left: 0,
          top: 0,
          bottom: 0,
        }}
      >  
        <div style={{ 
          height: '70px',
          display: 'flex', 
          alignItems: 'center', 
          justifyContent: 'center', 
          color: '#edbed8', /* Trắng hồng nhạt */
          fontWeight: 900, 
          fontSize: collapsed ? '20px' : '22px', /* Logo giữ size to để đẹp */
          letterSpacing: '1px',
          borderBottom: '1px solid rgba(255,255,255,0.06)'
        }}>
          {collapsed ? (
            <span style={{ color: '#6366F1' }}>BB</span> 
          ) : (
            <span>
              <span style={{ color: '#6366F1' }}>BEAUTY</span> BOOKING
            </span>
          )}
        </div>

        <Dropdown 
          menu={menuProps} 
          trigger={['click']} 
          placement={collapsed ? "rightTop" : "bottomRight"}
        >
          <div style={{ 
            margin: '16px',
            padding: collapsed ? '12px 0' : '12px 16px', 
            display: 'flex', 
            justifyContent: collapsed ? 'center' : 'flex-start',
            alignItems: 'center', 
            cursor: 'pointer',
            background: 'rgba(255, 255, 255, 0.05)', 
            borderRadius: '12px',
            transition: 'all 0.3s ease',
          }}
          onMouseEnter={(e) => e.currentTarget.style.background = 'rgba(255, 255, 255, 0.1)'} 
          onMouseLeave={(e) => e.currentTarget.style.background = 'rgba(255, 255, 255, 0.05)'}
          >
            <Avatar 
              src={user?.avatar} 
              icon={!user?.avatar && <UserOutlined />} 
              style={{ 
                backgroundColor: '#6366F1', 
                border: '2px solid rgba(255,255,255,0.1)',
              }} 
              size={collapsed ? 40 : 46} 
            >
              {user?.name ? user.name.charAt(0).toUpperCase() : ''}
            </Avatar>
            
            {!collapsed && (
              <div style={{ marginLeft: '14px', flex: 1, overflow: 'hidden' }}>
                <div style={{ 
                  color: '#FDF2F8', /* Trắng hồng nhạt */
                  fontWeight: 600, 
                  fontSize: '14px', /* Đồng bộ font 14px */
                  whiteSpace: 'nowrap', 
                  textOverflow: 'ellipsis', 
                  overflow: 'hidden' 
                }}>
                  {user?.name || user?.email || 'Administrator'}
                </div>
                <div style={{ color: '#10B981', fontSize: '13px', display: 'flex', alignItems: 'center', marginTop: '2px', fontWeight: 500 }}>
                  <div style={{ 
                    width: 8, height: 8, 
                    borderRadius: '50%', 
                    backgroundColor: '#10B981', 
                    marginRight: 6, 
                    boxShadow: '0 0 6px rgba(16, 185, 129, 0.4)'
                  }}></div>
                  Đang hoạt động
                </div>
              </div>
            )}
          </div>
        </Dropdown>

        <Menu 
          theme="dark" 
          mode="inline" 
          items={adminMenuItems} 
          onClick={handleMenuClick} 
          selectedKeys={[location.pathname]} 
          style={{ 
            border: 'none', 
            background: 'transparent', 
            padding: '0 8px',
            marginBottom: '24px',
            fontSize: '14px' /* Ép size 14px */
          }} 
        />
      </Sider>

      <Layout style={{ 
        background: '#F4F7FE',
        marginLeft: collapsed ? 80 : 280, 
        transition: 'all 0.2s', 
      }}>
        
        <Header style={{ 
          padding: '0 24px', 
          background: '#ffffff', 
          display: 'flex', 
          justifyContent: 'space-between', 
          alignItems: 'center', 
          height: '70px', 
          boxShadow: '0 2px 10px rgba(0, 0, 0, 0.02)',
          position: 'sticky',
          top: 0,
          zIndex: 9
        }}>
          <div style={{ display: 'flex', alignItems: 'center' }}>
            <Button
              type="text"
              icon={collapsed ? <MenuUnfoldOutlined /> : <MenuFoldOutlined />}
              onClick={() => setCollapsed(!collapsed)}
              style={{ 
                fontSize: '20px', 
                width: 40, height: 40, 
                marginLeft: '-12px',
                color: '#2B3674' 
              }}
            />
            <div style={{ 
              fontWeight: 700, 
              fontSize: '22px',
              color: '#2B3674', 
              marginLeft: '8px',
              letterSpacing: '-0.5px'
            }}>
              Bảng Điều Khiển
            </div>
          </div>
        </Header>

        <Content style={{ padding: '24px 24px 0 24px', flex: 1, overflow: 'initial' }}>
          <div style={{ 
            background: '#ffffff', 
            borderRadius: '20px', 
            minHeight: 'calc(100vh - 160px)', 
            padding: '24px', 
            boxShadow: '0px 4px 24px rgba(112, 144, 176, 0.08)' 
          }}>
            <Outlet />
          </div>
        </Content>
        
        <Footer style={{ 
          textAlign: 'center', 
          padding: '20px 24px', 
          color: '#A3AED1', 
          fontWeight: 500,
          fontSize: '13px'
        }}>
          BeautyBooking Admin Dashboard ©{new Date().getFullYear()}
        </Footer>
      </Layout>

      <ChangePasswordModal 
        open={isPwdModalOpen} 
        onClose={() => setIsPwdModalOpen(false)} 
      />
      
    </Layout>
  );
};

export default AdminLayout;