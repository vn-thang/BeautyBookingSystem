import React, { useState, useEffect } from 'react';
import { message } from 'antd'; 
import { reviewApi } from '../api/reviewApi';
import ReviewFilter from '../components/ReviewFilter';
import ReviewTable from '../components/ReviewTable';
import { masterDataApi } from '../../../api/masterDataApi';

import PageHeader from '../../../components/PageHeader';
import SectionCard from '../../../components/SectionCard';

const ReviewPage = () => {
  const [reviews, setReviews] = useState([]);
  const [loading, setLoading] = useState(false);
  const [stores, setStores] = useState([]);

  const [filters, setFilters] = useState({
    pageIndex: 1,
    pageSize: 10,
    storeId: null,
    rating: null,
    isHidden: null,
    searchTerm: '',
  });

  const [paginationInfo, setPaginationInfo] = useState({
    pageIndex: 1,
    pageSize: 10,
    totalCount: 0,
  });

  useEffect(() => {
    const fetchStores = async () => {
      try {
        const response = await masterDataApi.getStoresForDropdown();
        const resData = response.data || response;
        setStores(resData.items || resData.data || resData || []);
      } catch (error) {
        message.error("Không thể tải danh sách cửa hàng cho bộ lọc!");
      }
    };
    fetchStores();
  }, []);

  const fetchReviews = async () => {
    setLoading(true);
    try {
      const response = await reviewApi.getReviews(filters);
      const resData = response.data || response;
      const { items, totalCount, pageIndex, pageSize } = resData;
      
      setReviews(items || []);
      setPaginationInfo({ pageIndex, pageSize, totalCount });
    } catch (error) {
      if (error.response?.status === 401) {
        message.error('Phiên đăng nhập hết hạn, vui lòng đăng nhập lại!');
      } else {
        message.error('Không thể tải danh sách đánh giá!');
      }
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchReviews();
  }, [filters]);

  const handleTableChange = (pagination) => {
    setFilters((prev) => ({
      ...prev,
      pageIndex: pagination.current,
      pageSize: pagination.pageSize,
    }));
  };

  const handleFilterChange = (newFilters) => {
    setFilters((prev) => ({ ...prev, ...newFilters }));
  };

  const handleToggleVisibility = async (id, isHidden) => {
    try {
      const response = await reviewApi.toggleVisibility(id, isHidden);
      message.success(response.data?.message || 'Đã cập nhật trạng thái hiển thị!');
      fetchReviews(); 
    } catch (error) {
      message.error(error.response?.data?.message || 'Lỗi cập nhật trạng thái!');
    }
  };

  return (
    <div style={{ width: '100%', flex: 1, minWidth: 0 }}>
      <PageHeader title="Quản lý Đánh giá & Phản hồi" />

      <SectionCard>
        <ReviewFilter 
           filters={filters} 
           stores={stores} 
           onFilterChange={handleFilterChange} 
        />

        <ReviewTable 
          dataSource={reviews}
          loading={loading}
          pagination={paginationInfo}
          onTableChange={handleTableChange}
          onToggleVisibility={handleToggleVisibility}
        />

      </SectionCard>
    </div>
  );
};

export default ReviewPage;