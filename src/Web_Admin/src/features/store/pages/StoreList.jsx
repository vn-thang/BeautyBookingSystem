import React, { useState, useEffect } from 'react';
import { message, Space, Avatar, Select } from 'antd';
import { ShopOutlined } from '@ant-design/icons';

import { storeApi } from '../api/storeApi';
import { StoreStatus } from '../../../constants';

import StoreStatusTag from '../components/StoreStatusTag';
import StoreActions from '../components/StoreActions'; 

import PageHeader from '../../../components/PageHeader';
import SectionCard from '../../../components/SectionCard';
import FilterBar from '../../../components/FilterBar';
import CustomTable from '../../../components/CustomTable';

const StoreList = () => {
  const [stores, setStores] = useState([]);
  const [loading, setLoading] = useState(false);
  
  const [total, setTotal] = useState(0); 
  const [current, setCurrent] = useState(1); 
  const [pageSize, setPageSize] = useState(10); 

  const [searchText, setSearchText] = useState('');
  const [statusFilter, setStatusFilter] = useState(null);
  const [isDebtFilter, setIsDebtFilter] = useState(null);

  const fetchStores = async (page = current, size = pageSize, search = searchText, status = statusFilter, isDebt = isDebtFilter) => {
    setLoading(true);
    try {
      const params = { PageIndex: page, PageSize: size, SearchTerm: search };
      
      if (status !== null && status !== undefined) params.Status = status; 
      if (isDebt) params.IsDebt = true;

      const response = await storeApi.getAllStores(params); 
      setStores(response.items || response.Items || response.data || []); 
      setTotal(response.totalCount || response.TotalCount || response.total || 0); 
    } catch (error) {
      message.error('Không thể tải danh sách cửa hàng!');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchStores(1, 10); 
  }, []);

  const handleTableChange = (pagination) => {
    setCurrent(pagination.current);
    setPageSize(pagination.pageSize);
    fetchStores(pagination.current, pagination.pageSize, searchText, statusFilter, isDebtFilter);
  };

  const handleSearch = (value) => {
    setSearchText(value);
    setCurrent(1); 
    fetchStores(1, pageSize, value, statusFilter, isDebtFilter); 
  };

  const columns = [
    {
      title: 'Cửa Hàng',
      dataIndex: 'name',
      key: 'name',
      render: (text, record) => (
        <Space>
          <Avatar 
            shape="square" 
            size="large" 
            src={record.avatarUrl} 
            icon={!record.avatarUrl && <ShopOutlined />} 
            style={{ backgroundColor: '#f1f5f9', color: '#6366F1', borderRadius: '10px', objectFit: 'cover' }} 
          />
          <span style={{ fontWeight: 600, fontSize: '15px', color: '#1E293B' }}>{text}</span>
        </Space>
      )
    },
    {
      title: 'Chủ cửa hàng',
      dataIndex: 'ownerName',
      key: 'ownerName',
      render: (owner) => <span style={{ color: '#475569', fontWeight: 500 }}>{owner || 'N/A'}</span>
    },
    {
      title: 'Số điện thoại',
      dataIndex: 'phone',
      key: 'phone',
      render: (phone) => <span style={{ color: '#475569' }}>{phone || 'Chưa cập nhật'}</span>
    },
    {
      title: 'Trạng thái',
      dataIndex: 'status', 
      key: 'status',
      align: 'center',
      render: (status) => <StoreStatusTag status={status} />
    },
    {
      title: 'Hành động',
      key: 'action',
      align: 'center',
      render: (_, record) => <StoreActions record={record} />,
    },
  ];

  return (
    <div style={{ width: '100%', flex: 1, minWidth: 0 }}>
      <PageHeader title="Quản lý Cơ sở kinh doanh" />

      <SectionCard>
        <FilterBar 
          onSearch={handleSearch} 
          searchPlaceholder="Tìm kiếm theo tên cửa hàng..."
        >
          <Select
            placeholder="Tình trạng công nợ"
            defaultValue={null}
            style={{ width: 180 }}
            size="large"
            onChange={(val) => { setIsDebtFilter(val); setCurrent(1); fetchStores(1, pageSize, searchText, statusFilter, val); }}
            options={[
              { value: null, label: 'Tất cả cửa hàng' },
              { value: true, label: '⚠️ Đang nợ tiền' }
            ]}
          />

          <Select
            placeholder="Lọc trạng thái"
            allowClear 
            style={{ width: 160 }}
            size="large"
            onChange={(val) => { setStatusFilter(val); setCurrent(1); fetchStores(1, pageSize, searchText, val, isDebtFilter); }}
            options={[
              { value: StoreStatus.Pending, label: 'Chờ duyệt' },
              { value: StoreStatus.Approved, label: 'Đã duyệt' },
              { value: StoreStatus.Locked, label: 'Đã khóa' },
              { value: StoreStatus.Incomplete, label: 'Chưa hoàn thiện' }
            ]}
          />
        </FilterBar>

        <CustomTable 
          columns={columns} 
          dataSource={stores} 
          loading={loading}
          pagination={{ current, pageSize, total }}
          onChange={handleTableChange} 
        />

      </SectionCard>
    </div>
  );
};

export default StoreList;