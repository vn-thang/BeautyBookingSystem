import React, { useState, useEffect } from 'react';
import { Skeleton, message, Space, Button } from 'antd';
import { CheckCircleOutlined, LockOutlined, UnlockOutlined } from '@ant-design/icons';
import { useParams } from 'react-router-dom';
import { storeApi } from '../api/storeApi';
import { StoreStatus } from '../../../constants';

import StoreGeneralInfo from '../components/StoreDetail/StoreGeneralInfo';
import StoreOwnerInfo from '../components/StoreDetail/StoreOwnerInfo';
import StoreDocuments from '../components/StoreDetail/StoreDocuments';
import StoreFeeConfig from '../components/StoreDetail/StoreFeeConfig';

import PageHeader from '../../../components/PageHeader';
import SectionCard from '../../../components/SectionCard';

const StoreDetail = () => {
  const { id } = useParams();
  const [store, setStore] = useState(null);
  const [loading, setLoading] = useState(true);

  const fetchStoreDetail = async () => {
    setLoading(true);
    try {
      const response = await storeApi.getStoreById(id);
      setStore(response.data || response); 
    } catch (error) {
      message.error('Không thể tải thông tin chi tiết cửa hàng!');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (id) fetchStoreDetail();
  }, [id]);

  const handleStatusUpdate = async (newStatus, successMsg) => {
    try {
      if(newStatus === StoreStatus.Approved && store.status === StoreStatus.Pending) {
         await storeApi.approveStore(id);
      } else {
         await storeApi.updateStatus(id, newStatus);
      }
      message.success(successMsg);
      fetchStoreDetail();
    } catch (error) {
      message.error('Thao tác thất bại!');
    }
  };

  if (loading) return <Skeleton active avatar paragraph={{ rows: 8 }} />;
  if (!store) return <div>Không tìm thấy dữ liệu cửa hàng.</div>;

  return (
    <div style={{ width: '100%', maxWidth: '1200px', margin: '0 auto' }}>
      
      <PageHeader 
        title="Chi tiết Cơ sở kinh doanh" 
        showBack={true} 
        extra={
          <Space>
            {store.status === StoreStatus.Pending && (
              <Button type="primary" icon={<CheckCircleOutlined />} onClick={() => handleStatusUpdate(StoreStatus.Approved, 'Đã duyệt cửa hàng!')} style={{ backgroundColor: '#10b981' }}>Duyệt Cửa Hàng</Button>
            )}
            {store.status === StoreStatus.Approved && (
              <Button danger type="primary" icon={<LockOutlined />} onClick={() => handleStatusUpdate(StoreStatus.Locked, 'Đã khóa cửa hàng!')}>Khóa Hoạt Động</Button>
            )}
            {store.status === StoreStatus.Locked && (
              <Button type="primary" icon={<UnlockOutlined />} onClick={() => handleStatusUpdate(StoreStatus.Approved, 'Đã mở khóa cửa hàng!')} style={{ backgroundColor: '#f59e0b' }}>Mở Khóa</Button>
            )}
          </Space>
        }
      />

      <SectionCard title="I. Thông tin chung" titleColor="#0958d9">
        <StoreGeneralInfo store={store} />
      </SectionCard>

      <SectionCard title="II. Thông tin Chủ sở hữu" titleColor="#d46b08">
        <StoreOwnerInfo store={store} />
      </SectionCard>

      <SectionCard title="III. Tài liệu & Hình ảnh" titleColor="#389e0d">
        <StoreDocuments store={store} />
      </SectionCard>
      
      <SectionCard title="IV. Cấu hình Phí & Hoa hồng" titleColor="#722ed1">
        <StoreFeeConfig store={store} onConfigUpdated={fetchStoreDetail} />
      </SectionCard>

    </div>
  );
};

export default StoreDetail;