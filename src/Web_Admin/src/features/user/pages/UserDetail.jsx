import React, { useState, useEffect } from 'react';
import { Skeleton, message, Space, Typography, Descriptions, Row, Col, Button, Popconfirm } from 'antd';
import { StopOutlined, CheckCircleOutlined } from '@ant-design/icons';
import { useParams } from 'react-router-dom';

import { userApi } from '../api/userApi';
import { UserStatus } from '../../../constants';
import UserStatusTag from '../components/UserStatusTag';
import UserRoleTag from '../components/UserRoleTag';

import PageHeader from '../../../components/PageHeader';
import SectionCard from '../../../components/SectionCard';

const { Title, Text } = Typography;

const UserDetail = () => {
  const { id } = useParams();
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  const fetchUserDetail = async () => {
    setLoading(true);
    try {
      const response = await userApi.getUserById(id);
      setUser(response.data || response); 
    } catch (error) {
      message.error('Không thể tải thông tin chi tiết!');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { if (id) fetchUserDetail(); }, [id]);

  const handleUpdateStatus = async (newStatus) => {
    try {
      await userApi.updateUserStatus(id, newStatus);
      message.success('Cập nhật trạng thái thành công!');
      fetchUserDetail(); 
    } catch (error) {
      message.error(error.response?.data?.message || 'Cập nhật thất bại!');
    }
  };

  if (loading) return <Skeleton active avatar paragraph={{ rows: 8 }} />;
  if (!user) return <div>Không tìm thấy dữ liệu người dùng.</div>;

  return (
    <div style={{ width: '100%', maxWidth: '1200px', margin: '0 auto' }}>
      <PageHeader 
        title="Hồ sơ Người dùng" 
        showBack={true} 
        extra={
          <Space>
            {user.status === UserStatus.Locked ? (
              <Popconfirm title="Xác nhận mở khóa tài khoản này?" onConfirm={() => handleUpdateStatus(UserStatus.Active)}>
                <Button type="primary" icon={<CheckCircleOutlined />}>Kích hoạt lại</Button>
              </Popconfirm>
            ) : (
              <Popconfirm title="Xác nhận khóa tài khoản này?" onConfirm={() => handleUpdateStatus(UserStatus.Locked)}>
                <Button danger type="primary" icon={<StopOutlined />}>Khóa tài khoản</Button>
              </Popconfirm>
            )}
          </Space>
        }
      />

      <SectionCard title="I. Thông tin cá nhân" titleColor="#0958d9">
        <Descriptions 
          bordered column={1}
          labelStyle={{ width: '300px', backgroundColor: '#f8fafc', color: '#475569', fontWeight: 600 }}
          contentStyle={{ backgroundColor: '#ffffff' }}
        >
          <Descriptions.Item label="Trạng thái"><UserStatusTag status={user.status} /></Descriptions.Item>
          <Descriptions.Item label="Vai trò"><UserRoleTag role={user.role} /></Descriptions.Item>
          <Descriptions.Item label="Họ và Tên"><Text strong style={{ color: '#1E293B', fontSize: '15px' }}>{user.fullName}</Text></Descriptions.Item>
          <Descriptions.Item label="Email">{user.email}</Descriptions.Item>
          <Descriptions.Item label="Số điện thoại">
            {user.phone} {user.isPhoneVerified && <Text type="success" style={{ marginLeft: 8 }}>(Đã xác minh)</Text>}
          </Descriptions.Item>
          <Descriptions.Item label="Ngày tham gia">{new Date(user.createdAt).toLocaleDateString('vi-VN')}</Descriptions.Item>
        </Descriptions>
      </SectionCard>

      <SectionCard title="II. Thống kê hoạt động" titleColor="#722ed1">
        <Row gutter={[24, 24]}>
          <Col xs={24} md={8}>
            <div style={{ padding: '24px', backgroundColor: '#f8fafc', borderRadius: '16px', textAlign: 'center', border: '1px solid #e2e8f0' }}>
              <Title level={2} style={{ color: '#4318FF', margin: '0 0 8px 0' }}>{user.totalBookings}</Title>
              <Text style={{ color: '#64748b', fontWeight: 500 }}>Lượt Booking dịch vụ</Text>
            </div>
          </Col>
          <Col xs={24} md={8}>
            <div style={{ padding: '24px', backgroundColor: '#f8fafc', borderRadius: '16px', textAlign: 'center', border: '1px solid #e2e8f0' }}>
              <Title level={2} style={{ color: '#4318FF', margin: '0 0 8px 0' }}>{user.totalStores}</Title>
              <Text style={{ color: '#64748b', fontWeight: 500 }}>Cửa hàng sở hữu</Text>
            </div>
          </Col>
          <Col xs={24} md={8}>
            <div style={{ padding: '24px', backgroundColor: '#f8fafc', borderRadius: '16px', textAlign: 'center', border: '1px solid #e2e8f0' }}>
              <Title level={2} style={{ color: '#4318FF', margin: '0 0 8px 0' }}>{user.totalReviews}</Title>
              <Text style={{ color: '#64748b', fontWeight: 500 }}>Lượt đánh giá / Review</Text>
            </div>
          </Col>
        </Row>
      </SectionCard>
    </div>
  );
};

export default UserDetail;