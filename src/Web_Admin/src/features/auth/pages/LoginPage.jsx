import React, { useState } from 'react';
import { Form, Input, Button, Typography, message, Checkbox, ConfigProvider } from 'antd';
import { LockOutlined, MailOutlined, LeftOutlined, UserOutlined } from '@ant-design/icons';
import { useNavigate } from 'react-router-dom';
import styled from 'styled-components'; 
import { authApi } from '../api/authApi';
import { useAuth } from '../components/AuthContext';

const PageContainer = styled.div`
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: linear-gradient(135deg, #c1eae3 0%, #b4bcdb 100%);
`;

const StyledCard = styled.div`
  display: flex;
  width: 1040px;  
  max-width: 95%;  
  background: #e9cdd5;
  box-shadow: 0 20px 40px rgba(0,0,0,0.12);
  border-radius: 24px;
  overflow: hidden;
  position: relative;
`;

const SiderPanel = styled.div`
  flex: 1;
  background: #111827; 
  padding: 60px 40px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #ffffff;
  position: relative;
  
  &:after {
    content: "";
    position: absolute;
    top: 0;
    right: -30px; 
    height: 100%;
    width: 60px;
    background: #111827;
    transform: skewX(-6deg); 
    z-index: 1;
  }
`;

const ContentPanel = styled.div`
  flex: 1;
  background: #ffffff;
  padding: 60px 50px;
  position: relative;
  z-index: 2; 
`;

const CentralDividerButton = styled.div`
  width: 60px;
  height: 60px;
  background: #F1A1B5;
  border: 6px solid #111827; 
  border-radius: 50%;
  position: absolute;
  left: 50%; 
  top: 50%;
  transform: translate(-50%, -50%);
  display: flex;
  justify-content: center;
  align-items: center;
  color: #ffffff;
  font-size: 20px;
  cursor: pointer;
  z-index: 5; 
  transition: all 0.2s;
  
  &:hover {
    background: #ea8ea7;
  }
`;

const GradientButton = styled(Button)`
  font-weight: 700 !important;
  font-size: 16px !important;
  letter-spacing: 1px !important;
  box-shadow: 0 8px 16px rgba(181, 116, 137, 0.3) !important;
  border: none !important;
  height: 50px !important; 
  background: linear-gradient(135deg, #B57489 0%, #D4849A 100%) !important;
  
  &:hover {
    background: linear-gradient(135deg, #a7667a 0%, #c47187 100%) !important;
    opacity: 0.9;
  }
`;

const { Title, Text } = Typography;

const LoginPage = () => {
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();
  const { login } = useAuth(); 

  const onFinish = async (values) => {
    setLoading(true);
    try {
      const response = await authApi.login({
        emailOrPhone: values.username, 
        password: values.password,
        fcmToken: "" 
      });

      if (response.success) {
        login(response.data); 
        message.success('Đăng nhập hệ thống thành công!');
        navigate('/dashboard'); 
      }
    } catch (error) {
      console.error('Lỗi API:', error);
      const errorMsg = error.response?.data?.message || 'Tài khoản hoặc mật khẩu không chính xác!';
      message.error(errorMsg);
    } finally {
      setLoading(false); 
    }
  };

  return (
    <PageContainer>
      <ConfigProvider
        theme={{
          token: {
            colorPrimary: '#B57489', 
            borderRadius: 50, 
            colorBorder: '#E2E8F0', 
            controlHeight: 48, 
          },
        }}
      >
        <StyledCard>
          
          <CentralDividerButton onClick={() => message.info("Quay lại")}>
            <LeftOutlined />
          </CentralDividerButton>

          <SiderPanel>
            <div style={{ textAlign: 'center', marginBottom: '24px', zIndex: 10 }}>
              <div style={{ padding: '20px', background: '#ffffff', borderRadius: '50%', display: 'inline-flex', justifyContent: 'center', alignItems: 'center', marginBottom: '16px', boxShadow: '0 4px 10px rgba(0,0,0,0.1)' }}>
                <UserOutlined style={{ fontSize: '32px', color: '#6366F1' }} />
              </div>
              <Title level={2} style={{ color: '#ffffff', margin: 0, letterSpacing: '2px', fontWeight: 900, fontSize: '28px' }}>
                BEAUTY <span style={{ fontWeight: 400, color: '#F8FAFC' }}>BOOKING</span>
              </Title>
            </div>
            
            <Text style={{ color: '#E2E8F0', fontSize: '18px', textAlign: 'center', maxWidth: '300px', lineHeight: '1.6', zIndex: 10 }}>
              Chào mừng bạn đến với hệ thống Quản trị của chúng tôi.
            </Text>
          </SiderPanel>

          <ContentPanel>
         
            <div style={{ textAlign: 'center', marginBottom: 40 }}>
              <Title level={1} style={{ 
                color: '#111827', 
                margin: '0 0 8px 0', 
                fontSize: '32px',
                fontWeight: 800 
              }}>
                Welcome Back!
              </Title>
              <Text type="secondary" style={{ fontSize: '18px', color: '#64748b', fontWeight: 500 }}>
                Sign in to continue
              </Text>
              
              <div style={{ display: 'flex', justifyContent: 'center', gap: '6px', marginTop: '16px' }}>
                <span style={{ width: 6, height: 6, background: '#D1D5DB', borderRadius: '50%' }}></span>
                <span style={{ width: 6, height: 6, background: '#D1D5DB', borderRadius: '50%' }}></span>
                <span style={{ width: 10, height: 6, background: '#B57489', borderRadius: '4px' }}></span> 
              </div>
            </div>
            
            <Form 
              onFinish={onFinish} 
              layout="vertical"
              initialValues={{ remember: true }}
            >
              <Form.Item 
                name="username" 
                rules={[{ required: true, fontSize: '18px', message: 'Nhập Email hoặc Số điện thoại!' }]}
                style={{ marginBottom: 44 }}
              >
                <Input 
                  prefix={<MailOutlined style={{ color: '#94A3B8', marginRight: 12, fontSize: '18px' }} />} 
                  placeholder="Email" 
                  style={{ borderRadius: 50, background: '#F8FAFC' }} 
                />
              </Form.Item>

              <Form.Item 
                name="password" 
                rules={[{ required: true,fontSize: '18px', message: 'Nhập mật khẩu!' }]}
                style={{ marginBottom: 40 }}
              >
                <Input.Password 
                  prefix={<LockOutlined style={{ color: '#94A3B8', marginRight: 12, fontSize: '18px' }} />} 
                  placeholder="Password" 
                  style={{ borderRadius: 50, background: '#F8FAFC' }} 
                />
              </Form.Item>

              <div style={{ 
                display: 'flex', 
                justifyContent: 'space-between', 
                alignItems: 'center', 
                marginBottom: 32,
                padding: '0 8px'
              }}>
                <Form.Item name="remember" valuePropName="checked" noStyle>
                  <Checkbox>
                    <Text style={{ color: '#1E293B', fontSize: '18px', fontWeight: 600 }}>Remember me</Text>
                  </Checkbox>
                </Form.Item>
                <a 
                  href="#" 
                  style={{ color: '#94A3B8', fontSize: '18px', fontWeight: 500 }}
                  onClick={(e) => { e.preventDefault(); message.info("Quên mật khẩu?"); }}
                >
                  Forgot Password?
                </a>
              </div>

              <GradientButton 
                type="primary" 
                htmlType="submit" 
                loading={loading} 
                block
                style={{ borderRadius: 50 }} 
              >
                LOGIN
              </GradientButton>
            </Form>
            
          </ContentPanel>

        </StyledCard>
      </ConfigProvider>
    </PageContainer>
  );
};

export default LoginPage;