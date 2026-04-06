import React, { useState, useEffect } from 'react';
import { Button, message, Select } from 'antd';
import { PlusOutlined } from '@ant-design/icons';
import { categoryApi } from '../api/categoryApi';
import CategoryTable from '../components/CategoryTable';
import CategoryFormModal from '../components/CategoryFormModal';
import PageHeader from '../../../components/PageHeader';
import SectionCard from '../../../components/SectionCard';
import FilterBar from '../../../components/FilterBar';

const CategoryPage = () => {
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(false);
  
  const [isModalVisible, setIsModalVisible] = useState(false);
  const [editingCategory, setEditingCategory] = useState(null);
  const [submitLoading, setSubmitLoading] = useState(false);
  const [searchText, setSearchText] = useState('');
  const [statusFilter, setStatusFilter] = useState(null);

  const fetchCategories = async () => {
    setLoading(true);
    try {
      const response = await categoryApi.getAllForAdmin();
      setCategories(response.data || response || []); 
    } catch (error) {
      message.error('Không thể tải danh sách danh mục!');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchCategories(); }, []);

  const filteredCategories = categories.filter((cat) => {
    const matchName = cat.name?.toLowerCase().includes(searchText.toLowerCase());
    const matchStatus = statusFilter !== null ? cat.isActive === statusFilter : true;
    return matchName && matchStatus;
  });

  const handleOpenCreate = () => {
    setEditingCategory(null);
    setIsModalVisible(true);
  };

  const handleOpenEdit = (category) => {
    setEditingCategory(category);
    setIsModalVisible(true);
  };

  const handleDelete = async (id) => {
    try {
      await categoryApi.deleteCategory(id);
      message.success('Đã ẩn danh mục thành công!');
      fetchCategories();
    } catch (error) {
      message.error(error.response?.data?.message || 'Không thể ẩn danh mục này!');
    }
  };

  const handleSave = async (values) => {
    setSubmitLoading(true);
    try {
      if (editingCategory) {
        await categoryApi.updateCategory(editingCategory.id, values);
        message.success('Cập nhật thành công!');
      } else {
        await categoryApi.createCategory(values);
        message.success('Thêm mới thành công!');
      }
      setIsModalVisible(false);
      fetchCategories();
    } catch (error) {
      message.error(error.response?.data?.message || 'Có lỗi xảy ra!');
    } finally {
      setSubmitLoading(false);
    }
  };

  return (
    <div style={{ width: '100%', flex: 1, minWidth: 0 }}>
      
      <PageHeader 
        title="Quản lý Danh mục Dịch vụ" 
        extra={
          <Button type="primary" icon={<PlusOutlined />} onClick={handleOpenCreate}>
            Thêm danh mục mới
          </Button>
        }
      />

      <SectionCard>
        <FilterBar 
          onSearch={(val) => setSearchText(val)} 
          searchPlaceholder="Tìm tên danh mục..."
        >
          <Select
            placeholder="Lọc trạng thái"
            allowClear
            size="large"
            style={{ width: 200 }}
            onChange={(val) => setStatusFilter(val)}
            options={[
              { value: true, label: '🟢 Đang hiển thị' },
              { value: false, label: '⚪ Đã ẩn' }
            ]}
          />
        </FilterBar>

        <CategoryTable 
          dataSource={filteredCategories} 
          loading={loading} 
          onEdit={handleOpenEdit} 
          onDelete={handleDelete} 
        />
      </SectionCard>

      <CategoryFormModal 
        visible={isModalVisible}
        editingCategory={editingCategory}
        onCancel={() => setIsModalVisible(false)}
        onSave={handleSave}
        confirmLoading={submitLoading}
      />
    </div>
  );
};

export default CategoryPage;