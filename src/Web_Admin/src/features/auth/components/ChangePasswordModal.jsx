import React, { useState } from 'react';
import { Modal, Form, Input, Button, message, Space, Typography } from 'antd';
import { LockOutlined, SafetyCertificateOutlined } from '@ant-design/icons';
import { useAuth } from '@/features/auth/components/AuthContext';
import { authApi } from '@/features/auth/api/authApi';

const { Text } = Typography;

const ChangePasswordModal = ({ open, onClose }) => {
  const [loading, setLoading] = useState(false);
  const [form] = Form.useForm();
  const { logout } = useAuth();

  const handleFinish = async (values) => {
    setLoading(true);
    try {
      const response = await authApi.changePassword({
        oldPassword: values.oldPassword,
        newPassword: values.newPassword
      });

      if (response.success) { 
        message.success('Đổi mật khẩu thành công! Vui lòng đăng nhập lại.');
        form.resetFields();
        onClose(); 
        logout();  
      }
    } catch (error) {
      const errorMsg = error.response?.data?.message || 'Đổi mật khẩu thất bại. Vui lòng kiểm tra lại!';
      message.error(errorMsg);
    } finally {
      setLoading(false);
    }
  };

  const handleCancel = () => {
    form.resetFields();
    onClose();
  };

  return (
    <Modal
      title={
        <Space style={{ marginBottom: 12 }}>
            <div style={{ backgroundColor: '#F5F3FF', padding: '8px', borderRadius: '50%', display: 'flex' }}>
                <SafetyCertificateOutlined style={{ color: '#4318FF', fontSize: '18px' }} />
            </div>
            <Text strong style={{ fontSize: 18, color: '#1E293B' }}>Cập nhật Mật khẩu mới</Text>
        </Space>
      }
      open={open}
      onCancel={handleCancel}
      footer={null}
      centered
      destroyOnClose
      width={450}
    >
      <div style={{ backgroundColor: '#F8FAFC', padding: '12px 16px', borderRadius: '8px', border: '1px dashed #CBD5E1', marginBottom: '24px' }}>
          <Text type="secondary" style={{ fontSize: '13px', color: '#64748b' }}>
              ⚠️ Để bảo mật tài khoản, hệ thống sẽ tự động đăng xuất sau khi đổi mật khẩu thành công.
          </Text>
      </div>

      <Form form={form} layout="vertical" onFinish={handleFinish} size="large" requiredMark={false}>
        <Form.Item 
          name="oldPassword" 
          label={<Text strong style={{ color: '#1E293B' }}>Mật khẩu hiện tại</Text>}
          rules={[{ required: true, message: 'Vui lòng nhập mật khẩu hiện tại!' }]}
        >
          <Input.Password 
            prefix={<LockOutlined style={{ color: '#94a3b8' }} />} 
            placeholder="Nhập mật khẩu đang sử dụng..." 
            style={{ borderRadius: '8px' }} 
          />
        </Form.Item>

        <Form.Item 
          name="newPassword" 
          label={<Text strong style={{ color: '#1E293B' }}>Mật khẩu mới</Text>}
          rules={[
            { required: true, message: 'Vui lòng nhập mật khẩu mới!' },
            { min: 6, message: 'Mật khẩu phải có ít nhất 6 ký tự!' }
          ]}
        >
          <Input.Password 
            prefix={<LockOutlined style={{ color: '#94a3b8' }} />} 
            placeholder="Tối thiểu 6 ký tự..." 
            style={{ borderRadius: '8px' }} 
          />
        </Form.Item>

        <Form.Item 
          name="confirmPassword" 
          label={<Text strong style={{ color: '#1E293B' }}>Xác nhận mật khẩu mới</Text>}
          dependencies={['newPassword']}
          rules={[
            { required: true, message: 'Vui lòng xác nhận lại mật khẩu!' },
            ({ getFieldValue }) => ({
              validator(_, value) {
                if (!value || getFieldValue('newPassword') === value) {
                  return Promise.resolve();
                }
                return Promise.reject(new Error('Mật khẩu xác nhận không khớp với mật khẩu mới!'));
              },
            }),
          ]}
        >
          <Input.Password 
            prefix={<LockOutlined style={{ color: '#94a3b8' }} />} 
            placeholder="Nhập lại mật khẩu mới ở trên..." 
            style={{ borderRadius: '8px' }} 
          />
        </Form.Item>

        <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', marginTop: '32px' }}>
          <Button onClick={handleCancel} style={{ borderRadius: '8px' }}>
            Hủy bỏ
          </Button>
          <Button 
            type="primary" 
            htmlType="submit" 
            loading={loading} 
            style={{ borderRadius: '8px', backgroundColor: '#4318FF' }}
          >
            Cập nhật mật khẩu
          </Button>
        </div>
      </Form>
    </Modal>
  );
};

export default ChangePasswordModal;