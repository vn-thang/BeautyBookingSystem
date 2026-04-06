import React, { useState, useEffect } from 'react';
import { message } from 'antd';
import { walletApi } from '../api/walletApi'; 

import WalletTable from '../components/WalletTable';
import AdjustWalletModal from '../components/AdjustWalletModal';
import WalletFilterBar from '../components/WalletFilterBar';
import PageHeader from '../../../components/PageHeader';
import SectionCard from '../../../components/SectionCard';

const WalletHistoryPage = () => {
    const [transactions, setTransactions] = useState([]);
    const [loading, setLoading] = useState(false);
    
    const [filters, setFilters] = useState({
        storeName: '',
        type: null,
        dateRange: null
    });

    const [pagination, setPagination] = useState({
        current: 1,
        pageSize: 10,
        total: 0,
    });

    const [isModalOpen, setIsModalOpen] = useState(false);
    const [selectedStore, setSelectedStore] = useState(null);

    const fetchTransactions = async (
        page = pagination.current,
        size = pagination.pageSize,
        currentFilters = filters
    ) => {
        setLoading(true);
        try {
            const searchParams = {
                pageIndex: page,
                pageSize: size,
                storeName: currentFilters.storeName || undefined,
                type: currentFilters.type || undefined,
                startDate: currentFilters.dateRange?.[0] ? currentFilters.dateRange[0].startOf('day').toISOString() : undefined,
                endDate: currentFilters.dateRange?.[1] ? currentFilters.dateRange[1].endOf('day').toISOString() : undefined,
            };

            const res = await walletApi.getTransactions(searchParams);

            setTransactions(res.data?.items || []);
            setPagination(prev => ({
                ...prev,
                current: page,
                pageSize: size,
                total: res.data?.totalCount || 0,
            }));

        } catch (error) {
            console.error("Fetch error:", error);
            message.error('Không thể tải dữ liệu giao dịch!');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchTransactions(1, pagination.pageSize, filters);
    }, [filters.type, filters.dateRange]);

    const handleSearch = (searchValue) => {
        const newFilters = { ...filters, storeName: searchValue };
        setFilters(newFilters);
        fetchTransactions(1, pagination.pageSize, newFilters);
    };
    
    const handleReset = () => {
        const defaultFilters = { storeName: '', type: null, dateRange: null };
        setFilters(defaultFilters);
        fetchTransactions(1, pagination.pageSize, defaultFilters);
    };

    const handleTableChange = (newPagination) => {
        fetchTransactions(newPagination.current, newPagination.pageSize, filters);
    };

    const handleOpenModal = (storeId, storeName) => {
        setSelectedStore({ id: storeId, name: storeName });
        setIsModalOpen(true);
    };

    const handleAdjustSubmit = async (formData) => {
        try {
            const res = await walletApi.adjustBalance(selectedStore.id, formData);
            if (res.data?.success) {
                message.success('Điều chỉnh số dư thành công!');
                setIsModalOpen(false);
                fetchTransactions(1); 
            } else {
                message.error(res.data?.message || 'Có lỗi xảy ra');
            }
        } catch (error) {
            message.error('Lỗi: ' + (error.response?.data?.message || 'Thao tác thất bại'));
        }
    };

    return (
        <div style={{ width: '100%', flex: 1, minWidth: 0 }}>
            <PageHeader title="Lịch sử Biến động Số dư (Wallet)" />
            <SectionCard>
                <WalletFilterBar 
                    filters={filters}
                    setFilters={setFilters}
                    onSearch={handleSearch}
                    onReset={handleReset}
                />

                <WalletTable 
                    transactions={transactions}
                    loading={loading}
                    pagination={pagination}
                    onChange={handleTableChange}
                    onOpenAdjustModal={handleOpenModal}
                />
            </SectionCard>

            <AdjustWalletModal 
                isOpen={isModalOpen}
                onClose={() => setIsModalOpen(false)}
                onSubmit={handleAdjustSubmit}
                store={selectedStore}
            />
        </div>
    );
};

export default WalletHistoryPage;