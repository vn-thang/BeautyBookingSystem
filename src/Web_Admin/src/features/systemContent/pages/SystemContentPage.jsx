import React, { useEffect, useState } from 'react';
import { Button, message, Space, Tooltip, Typography } from 'antd';
import { EditOutlined, PlusOutlined } from '@ant-design/icons';
import { systemContentApi } from '../api/systemContentApi';
import dayjs from 'dayjs';

import ContentEditorDrawer from '../components/ContentEditorDrawer';
import ContentViewDrawer from '../components/ContentViewDrawer';
import PageHeader from '../../../components/PageHeader';
import SectionCard from '../../../components/SectionCard';
import CustomTable from '../../../components/CustomTable';

const { Text } = Typography;

const SystemContentPage = () => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  
  const [drawerOpen, setDrawerOpen] = useState(false);
  const [selectedId, setSelectedId] = useState(null);

  const [viewOpen, setViewOpen] = useState(false);
  const [viewId, setViewId] = useState(null);

  const fetchList = async () => {
    setLoading(true);
    try {
      const res = await systemContentApi.getAllAdmin();
      const listData = Array.isArray(res) ? res : (res.data || []);
      setData(listData);
    } catch (error) {
      message.error('Lỗi khi tải danh sách nội dung!');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchList(); }, []);

  const handleEdit = (id) => {
    setSelectedId(id);
    setDrawerOpen(true);
  };

  const handleView = (id) => {
    setViewId(id);
    setViewOpen(true);
  };

  const columns = [
    {
      title: 'Mã bài viết',
      dataIndex: 'id',
      key: 'id',
      width: 120,
      render: (id) => <Text strong style={{ color: '#4318FF' }}>CTX-{id}</Text>
    },
    {
      title: 'Tiêu đề hiển thị',
      dataIndex: 'title',
      key: 'title',
      render: (text, record) => (
        <a 
          onClick={() => handleView(record.id)} 
          style={{ fontWeight: 600, color: '#1E293B', fontSize: '15px' }}
        >
          {text}
        </a>
      ),
    },
    {
      title: 'Trạng thái',
      dataIndex: 'isActive',
      key: 'isActive',
      width: 140,
      align: 'center',
      render: (isActive) => (
        <span style={{ 
          backgroundColor: isActive ? '#d1fae5' : '#f1f5f9', 
          color: isActive ? '#10b981' : '#64748b', 
          padding: '4px 12px', 
          borderRadius: '6px', 
          fontWeight: 600, 
          fontSize: '12px' 
        }}>
          {isActive ? 'ĐANG BẬT' : 'ĐANG TẮT'}
        </span>
      ),
    },
    {
      title: 'Cập nhật lần cuối',
      dataIndex: 'updatedAt',
      key: 'updatedAt',
      width: 200,
      render: (date) => (
        <Text style={{ color: '#475569' }}>
          {date ? dayjs(date).format('DD/MM/YYYY HH:mm') : '---'}
        </Text>
      ),
    },
    {
      title: 'Thao tác',
      key: 'action',
      width: 100,
      align: 'center',
      render: (_, record) => (
        <Space size="middle">
          <Tooltip title="Chỉnh sửa nội dung">
            <Button 
              type="text" 
              icon={<EditOutlined style={{ color: '#4318FF', fontSize: '18px' }} />} 
              onClick={() => handleEdit(record.id)}
              style={{ background: 'rgba(67, 24, 255, 0.05)', borderRadius: '8px' }}
            />
          </Tooltip>
        </Space>
      ),
    },
  ];

  return (
    <div style={{ width: '100%', flex: 1, minWidth: 0 }}>
      <PageHeader 
        title="Quản lý Bài viết & Chính sách" 
        extra={
          <Button 
            type="primary" 
            icon={<PlusOutlined />} 
            onClick={() => { setSelectedId(null); setDrawerOpen(true); }}
            style={{ backgroundColor: '#4318FF' }}
            size="large"
          >
            Soạn bài mới
          </Button>
        }
      />

      <SectionCard>
        <CustomTable 
          columns={columns} 
          dataSource={data} 
          rowKey="id" 
          loading={loading}
          pagination={{ pageSize: 10 }} 
        />
      </SectionCard>

      <ContentEditorDrawer 
        open={drawerOpen}
        onClose={() => setDrawerOpen(false)}
        contentId={selectedId}
        onSuccess={fetchList}
      />

      <ContentViewDrawer
        open={viewOpen}
        onClose={() => setViewOpen(false)}
        contentId={viewId}
      />
    </div>
  );
};

export default SystemContentPage;