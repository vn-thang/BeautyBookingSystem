import React, { useState, useEffect } from 'react';
import { message, Space, Avatar, Select, Button } from 'antd';
import { UserOutlined, EyeOutlined } from '@ant-design/icons';
import { useNavigate } from 'react-router-dom';

import { userApi } from '../api/userApi';
import { UserRole, UserStatus } from '../../../constants'; // Thêm UserStatus

import UserStatusTag from '../components/UserStatusTag';
import UserRoleTag from '../components/UserRoleTag';
import PageHeader from '../../../components/PageHeader';
import SectionCard from '../../../components/SectionCard';
import FilterBar from '../../../components/FilterBar';
import CustomTable from '../../../components/CustomTable';

const UserList = () => {
  const navigate = useNavigate();
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(false);
  const [total, setTotal] = useState(0); 
  const [current, setCurrent] = useState(1); 
  const [pageSize, setPageSize] = useState(10); 
  
  const [searchTerm, setSearchTerm] = useState('');
  const [roleFilter, setRoleFilter] = useState(null);
  const [statusFilter, setStatusFilter] = useState(null);

  const fetchUsers = async (page = current, size = pageSize, search = searchTerm, role = roleFilter, status = statusFilter) => {
    setLoading(true);
    try {
      const params = { PageIndex: page, PageSize: size };
      if (search) params.SearchTerm = search;
      if (role !== null && role !== undefined) params.Role = role;
      if (status !== null && status !== undefined) params.Status = status;

      const response = await userApi.getAllUsers(params);
      setUsers(response.items || response.data?.items || []);
      setTotal(response.totalCount || response.data?.totalCount || 0);
    } catch (error) {
      message.error('Không thể tải danh sách người dùng!');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchUsers(1, 10); }, []);

  const handleTableChange = (pagination) => {
    setCurrent(pagination.current);
    setPageSize(pagination.pageSize);
    fetchUsers(pagination.current, pagination.pageSize, searchTerm, roleFilter, statusFilter);
  };

  const handleSearch = (value) => {
    setSearchTerm(value);
    setCurrent(1);
    fetchUsers(1, pageSize, value, roleFilter, statusFilter);
  };

  const columns = [
    {
      title: 'Người dùng',
      dataIndex: 'fullName',
      render: (text, record) => (
        <Space>
          <Avatar size="large" src={record.avatarUrl} icon={!record.avatarUrl && <UserOutlined />} style={{ backgroundColor: '#f1f5f9', color: '#4318FF' }} />
          <span style={{ fontWeight: 600, fontSize: '15px', color: '#1E293B' }}>{text || 'Chưa cập nhật'}</span>
        </Space>
      )
    },
    {
      title: 'Liên hệ',
      render: (_, record) => (
        <div style={{ color: '#475569' }}>
          <div>{record.email}</div>
          <div style={{ fontWeight: 500 }}>{record.phone}</div>
        </div>
      )
    },
    {
      title: 'Vai trò',
      dataIndex: 'role',
      align: 'center',
      render: (role) => <UserRoleTag role={role} />
    },
    {
      title: 'Trạng thái',
      dataIndex: 'status', 
      align: 'center',
      render: (status) => <UserStatusTag status={status} />
    },
    {
      title: 'Hành động',
      align: 'center',
      render: (_, record) => (
        <Button type="default" icon={<EyeOutlined />} size="small" onClick={() => navigate(`/users/${record.id}`)}>
          Chi tiết
        </Button>
      ),
    },
  ];

  return (
    <div style={{ width: '100%', flex: 1, minWidth: 0 }}>
      <PageHeader title="Quản lý Người Dùng" />

      <SectionCard>
        <FilterBar onSearch={handleSearch} searchPlaceholder="Tìm tên, email, SĐT...">
          <Select
            placeholder="Lọc vai trò"
            allowClear 
            style={{ width: 160 }}
            size="large"
            onChange={(val) => { setRoleFilter(val); setCurrent(1); fetchUsers(1, pageSize, searchTerm, val, statusFilter); }}
            options={[
              { value: UserRole.Customer, label: 'Khách hàng' },
              { value: UserRole.StoreOwner, label: 'Chủ cửa hàng' },
              { value: UserRole.Admin, label: 'Admin' }
            ]}
          />
          <Select
            placeholder="Lọc trạng thái"
            allowClear 
            style={{ width: 160 }}
            size="large"
            onChange={(val) => { setStatusFilter(val); setCurrent(1); fetchUsers(1, pageSize, searchTerm, roleFilter, val); }}
            options={[
              { value: UserStatus.Active, label: 'Hoạt động' },
              { value: UserStatus.Locked, label: 'Bị Khóa' },
            ]}
          />
        </FilterBar>
        <CustomTable 
          columns={columns} 
          dataSource={users} 
          loading={loading}
          pagination={{ current, pageSize, total }}
          onChange={handleTableChange} 
        />
      </SectionCard>
    </div>
  );
};

export default UserList;